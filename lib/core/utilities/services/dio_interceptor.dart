import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../resources/constants.dart';
import 'cache_service.dart';
import 'secure_cache_service.dart';
import '../functions/secure_logger.dart';

class DioInterceptor extends Interceptor {
  static bool isDialogShowing = false;
  static DateTime? _lastTokenRefresh;
  static const Duration _tokenRefreshInterval = Duration(minutes: 5);

  const DioInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // SECURITY FIX: Load token from secure storage instead of SharedPreferences
    // Addresses CWE-311 (Missing Encryption of Sensitive Data)

    // Check and refresh Firebase token if needed
    // Addresses CWE-613 (Insufficient Session Expiration)
    await _refreshFirebaseTokenIfNeeded();

    final token = await SecureCacheService.getToken();
    final baseUrl = await SecureCacheService.getBaseUrl();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (baseUrl != null) {
      options.baseUrl = baseUrl;
    }

    super.onRequest(options, handler);
  }

  /// Refresh Firebase token if it's about to expire
  /// Prevents 401 errors by proactively refreshing tokens
  static Future<void> _refreshFirebaseTokenIfNeeded() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Check if we need to refresh based on time
      final now = DateTime.now();
      if (_lastTokenRefresh != null &&
          now.difference(_lastTokenRefresh!) < _tokenRefreshInterval) {
        // Token was refreshed recently, skip
        return;
      }

      // Force token refresh to get a fresh token
      // Firebase tokens typically expire after 1 hour
      final idToken = await currentUser.getIdToken(true); // true = force refresh

      if (idToken != null) {
        // Update token in secure storage
        await SecureCacheService.setToken(idToken);
        _lastTokenRefresh = now;

        SecureLogger.info('Token refreshed successfully', tag: 'Auth');
      }
    } catch (e) {
      SecureLogger.error(
        'Failed to refresh Firebase token',
        tag: 'Auth',
        error: e,
      );
      // Don't throw - allow request to proceed with existing token
      // If token is expired, backend will return 401 and we'll handle it in onError
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == AppConstants.unauthenticated &&
        !isDialogShowing) {

      final currentToken = await SecureCacheService.getToken();

      if (currentToken != null) {
        SecureLogger.warning(
          'Received 401 Unauthorized - attempting token refresh',
          tag: 'Auth',
        );

        // Try to refresh token one more time
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            final freshToken = await currentUser.getIdToken(true);

            if (freshToken != null && freshToken != currentToken) {
              // Token was refreshed successfully
              await SecureCacheService.setToken(freshToken);
              _lastTokenRefresh = DateTime.now();

              SecureLogger.info('Token refreshed after 401, retrying request', tag: 'Auth');

              // Retry the original request with new token
              final options = err.requestOptions;
              options.headers['Authorization'] = 'Bearer $freshToken';

              try {
                final response = await Dio().request(
                  options.path,
                  data: options.data,
                  queryParameters: options.queryParameters,
                  options: Options(
                    method: options.method,
                    headers: options.headers,
                  ),
                );
                return handler.resolve(response);
              } catch (retryError) {
                // Retry failed, proceed with error
                SecureLogger.error(
                  'Request retry failed after token refresh',
                  tag: 'Auth',
                  error: retryError,
                );
              }
            }
          }
        } catch (refreshError) {
          SecureLogger.error(
            'Failed to refresh token on 401',
            tag: 'Auth',
            error: refreshError,
          );
        }

        // Show authentication error dialog only once
        isDialogShowing = true;
      }
    }

    super.onError(err, handler);
  }

  /// Reset token refresh state (call this on logout)
  static void resetTokenRefreshState() {
    _lastTokenRefresh = null;
    isDialogShowing = false;
  }
}
