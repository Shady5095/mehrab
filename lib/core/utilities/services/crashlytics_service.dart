import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../functions/secure_logger.dart';

/// Service for Firebase Crashlytics integration
/// Provides centralized error reporting, user tracking, and breadcrumb logging
///
/// Features:
/// - Automatic crash reporting
/// - Custom error logging with severity levels
/// - User identification for crash reports
/// - Breadcrumb logging for user actions
/// - Custom key-value pairs for context
class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize Crashlytics settings
  static Future<void> init() async {
    try {
      // Enable crash collection (can be disabled for debug builds if needed)
      // await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      SecureLogger.info('Crashlytics initialized', tag: 'CrashlyticsService');
    } catch (e) {
      SecureLogger.error('Failed to initialize Crashlytics',
          tag: 'CrashlyticsService', error: e);
    }
  }

  /// Set user identifier for crash reports
  /// This helps identify which user experienced a crash
  static Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      SecureLogger.info('User ID set in Crashlytics: $userId',
          tag: 'CrashlyticsService');
    } catch (e) {
      SecureLogger.error('Failed to set user ID',
          tag: 'CrashlyticsService', error: e);
    }
  }

  /// Set custom key-value pairs for crash context
  /// Examples: app version, feature flags, user role, etc.
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      SecureLogger.error('Failed to set custom key: $key',
          tag: 'CrashlyticsService', error: e);
    }
  }

  /// Set multiple custom keys at once
  static Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    try {
      for (final entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    } catch (e) {
      SecureLogger.error('Failed to set custom keys',
          tag: 'CrashlyticsService', error: e);
    }
  }

  /// Log a breadcrumb (user action or event)
  /// Breadcrumbs help understand what the user was doing before a crash
  static void logBreadcrumb(String message, {Map<String, dynamic>? data}) {
    try {
      final logMessage = data != null ? '$message: ${data.toString()}' : message;
      _crashlytics.log(logMessage);

      if (kDebugMode) {
        SecureLogger.info('Breadcrumb: $logMessage', tag: 'CrashlyticsService');
      }
    } catch (e) {
      SecureLogger.error('Failed to log breadcrumb',
          tag: 'CrashlyticsService', error: e);
    }
  }

  /// Record a non-fatal error (won't crash the app but should be tracked)
  static Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Add context as custom keys if provided
      if (context != null) {
        await setCustomKeys(context);
      }

      // Record the error
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      if (kDebugMode) {
        SecureLogger.error(
          reason ?? 'Recorded error',
          tag: 'CrashlyticsService',
          error: error,
        );
      }
    } catch (e) {
      SecureLogger.error('Failed to record error',
          tag: 'CrashlyticsService', error: e);
    }
  }

  /// Record a Flutter error (from ErrorWidget or FlutterError)
  static Future<void> recordFlutterError(FlutterErrorDetails details) async {
    try {
      await _crashlytics.recordFlutterError(details);

      if (kDebugMode) {
        SecureLogger.error(
          'Flutter Error',
          tag: 'CrashlyticsService',
          error: details.exception,
        );
      }
    } catch (e) {
      SecureLogger.error('Failed to record Flutter error',
          tag: 'CrashlyticsService', error: e);
    }
  }

  /// Force a test crash (for testing Crashlytics setup)
  /// ⚠️ WARNING: This will crash the app! Use only for testing.
  static void testCrash() {
    _crashlytics.crash();
  }

  /// Send test exception (non-fatal, for testing reporting)
  static Future<void> testException() async {
    try {
      throw Exception('Test exception from Crashlytics');
    } catch (e, stack) {
      await recordError(
        e,
        stack,
        reason: 'Testing Crashlytics exception reporting',
      );
    }
  }

  /// Check if crash reporting is enabled
  static Future<bool> isCrashlyticsCollectionEnabled() async {
    try {
      return _crashlytics.isCrashlyticsCollectionEnabled;
    } catch (e) {
      SecureLogger.error('Failed to check Crashlytics status',
          tag: 'CrashlyticsService', error: e);
      return false;
    }
  }

  /// Enable or disable crash collection at runtime
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      SecureLogger.info('Crashlytics collection ${enabled ? 'enabled' : 'disabled'}',
          tag: 'CrashlyticsService');
    } catch (e) {
      SecureLogger.error('Failed to set Crashlytics collection',
          tag: 'CrashlyticsService', error: e);
    }
  }

  // ========== Helper Methods for Common Scenarios ==========

  /// Log API error with details
  static Future<void> logApiError({
    required String endpoint,
    required int statusCode,
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    await setCustomKeys({
      'api_endpoint': endpoint,
      'status_code': statusCode,
      'error_type': 'api_error',
    });
    await recordError(
      error,
      stackTrace,
      reason: 'API Error: $endpoint (Status: $statusCode)',
    );
  }

  /// Log authentication error
  static Future<void> logAuthError({
    required String authMethod,
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    await setCustomKeys({
      'auth_method': authMethod,
      'error_type': 'auth_error',
    });
    await recordError(
      error,
      stackTrace,
      reason: 'Auth Error: $authMethod',
    );
  }

  /// Log navigation error
  static Future<void> logNavigationError({
    required String route,
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    await setCustomKeys({
      'route': route,
      'error_type': 'navigation_error',
    });
    await recordError(
      error,
      stackTrace,
      reason: 'Navigation Error: $route',
    );
  }

  /// Log permission error
  static Future<void> logPermissionError({
    required String permission,
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    await setCustomKeys({
      'permission': permission,
      'error_type': 'permission_error',
    });
    await recordError(
      error,
      stackTrace,
      reason: 'Permission Error: $permission',
    );
  }

  /// Log LiveKit/call error
  static Future<void> logCallError({
    required String callId,
    required String errorType,
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    await setCustomKeys({
      'call_id': callId,
      'call_error_type': errorType,
      'error_type': 'livekit_error',
    });
    await recordError(
      error,
      stackTrace,
      reason: 'Call Error: $errorType',
    );
  }

  /// Log user session information
  static Future<void> setUserContext({
    required String userId,
    String? userRole,
    String? userEmail,
    Map<String, dynamic>? customAttributes,
  }) async {
    await setUserId(userId);

    final attributes = {
      if (userRole != null) 'user_role': userRole,
      if (userEmail != null) 'user_email': userEmail,
      ...?customAttributes,
    };

    await setCustomKeys(attributes);
  }

  /// Clear user context on logout
  static Future<void> clearUserContext() async {
    try {
      await _crashlytics.setUserIdentifier('');
      SecureLogger.info('User context cleared', tag: 'CrashlyticsService');
    } catch (e) {
      SecureLogger.error('Failed to clear user context',
          tag: 'CrashlyticsService', error: e);
    }
  }
}
