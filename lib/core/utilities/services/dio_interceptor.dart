import 'package:dio/dio.dart';
import '../resources/constants.dart';
import 'cache_service.dart';
import 'secure_cache_service.dart';

class DioInterceptor extends Interceptor {
  static bool isDialogShowing = false;

  const DioInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // SECURITY FIX: Load token from secure storage instead of SharedPreferences
    // Addresses CWE-311 (Missing Encryption of Sensitive Data)
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

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == AppConstants.unauthenticated &&
        !isDialogShowing &&
        CacheService.token != null) {
      isDialogShowing = true;
    }
    super.onError(err, handler);
  }
}
