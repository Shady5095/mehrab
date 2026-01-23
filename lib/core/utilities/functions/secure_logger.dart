import 'package:flutter/foundation.dart';

/// Secure logging utility to prevent sensitive information leakage
///
/// Security Issue: CWE-532 (Insertion of Sensitive Information into Log File)
/// This wrapper ensures:
/// - Debug logs are only shown in debug mode
/// - Sensitive data is never logged in production
/// - Production builds strip all debug logs (with ProGuard/R8)
class SecureLogger {
  /// Standard log for general information
  /// Only outputs in debug mode, stripped in release builds
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  /// Info level logging for important but non-sensitive events
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[INFO][$tag] ' : '[INFO] ';
      debugPrint('$prefix$message');
    }
  }

  /// Warning level logging for potential issues
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[WARNING][$tag] ' : '[WARNING] ';
      debugPrint('$prefix$message');
    }
  }

  /// Error level logging for errors
  /// Note: Stack traces may contain sensitive paths in production
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[ERROR][$tag] ' : '[ERROR] ';
      debugPrint('$prefix$message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
    } else {
      // In production, only log generic error message
      // Use crash reporting service (Firebase Crashlytics) for detailed errors
      debugPrint('Error occurred. Check crash reporting for details.');
    }
  }

  /// ⚠️ NEVER USE IN PRODUCTION
  /// This method is for development debugging only
  /// It will NEVER log in release builds regardless of parameter
  ///
  /// Use this only for:
  /// - Temporary debugging during development
  /// - Data that could contain sensitive information
  ///
  /// Examples of sensitive data to NEVER log:
  /// - Authentication tokens
  /// - User passwords or credentials
  /// - API keys or secrets
  /// - Personal Identifiable Information (PII)
  /// - Payment information
  /// - Session IDs
  /// - Email addresses (in most cases)
  /// - Phone numbers
  /// - User IDs that could be traced
  static void sensitive(String message, {String? tag}) {
    // NEVER log in production - always check kDebugMode
    if (kDebugMode) {
      final prefix = tag != null ? '[SENSITIVE][$tag] ' : '[SENSITIVE] ';
      debugPrint('$prefix⚠️  $message');
    }
    // In release mode, this is completely stripped out
  }

  /// Network request logging (sanitized)
  /// Logs request details without sensitive headers or body content
  static void network({
    required String method,
    required String url,
    int? statusCode,
    String? tag,
  }) {
    if (kDebugMode) {
      final prefix = tag != null ? '[NETWORK][$tag] ' : '[NETWORK] ';
      final status = statusCode != null ? ' - Status: $statusCode' : '';
      debugPrint('$prefix$method $url$status');
    }
  }

  /// WebRTC signaling events (without sensitive data)
  static void webrtc(String event, {String? details, String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[WEBRTC][$tag] ' : '[WEBRTC] ';
      final detailsStr = details != null ? ' - $details' : '';
      debugPrint('$prefix$event$detailsStr');
    }
  }

  /// Firebase events logging
  static void firebase(String event, {String? details, String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[FIREBASE][$tag] ' : '[FIREBASE] ';
      final detailsStr = details != null ? ' - $details' : '';
      debugPrint('$prefix$event$detailsStr');
    }
  }

  /// User action tracking (for analytics, not debugging)
  /// Should be sent to analytics service, not logged
  static void analytics(String event, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      debugPrint('[ANALYTICS] Event: $event');
      if (parameters != null && parameters.isNotEmpty) {
        debugPrint('[ANALYTICS] Parameters: ${_sanitizeParameters(parameters)}');
      }
    }
    // In production, send to Firebase Analytics instead of logging
  }

  /// Sanitize parameters to remove sensitive data
  static Map<String, dynamic> _sanitizeParameters(Map<String, dynamic> params) {
    final sanitized = <String, dynamic>{};
    final sensitiveKeys = [
      'password',
      'token',
      'secret',
      'key',
      'credential',
      'auth',
      'email',
      'phone',
      'credit_card',
      'ssn',
    ];

    params.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (sensitiveKeys.any((sensitive) => lowerKey.contains(sensitive))) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  /// Development-only method for dumping object state
  /// Never called in production
  static void dump(String label, Object? object) {
    if (kDebugMode) {
      debugPrint('[DUMP] $label:');
      debugPrint(object.toString());
    }
  }

  /// Assert wrapper for production safety
  /// In production, assertions are disabled, but this provides a way to log
  static void assertion(bool condition, String message) {
    assert(() {
      if (!condition) {
        debugPrint('[ASSERTION FAILED] $message');
      }
      return true;
    }());
  }
}

/// Extension method for easier migration from debugPrint
extension SecureLoggerExtension on String {
  /// Quick log method: 'Hello'.log()
  void log({String? tag}) => SecureLogger.log(this, tag: tag);

  /// Quick info log: 'User logged in'.info()
  void info({String? tag}) => SecureLogger.info(this, tag: tag);

  /// Quick warning: 'Deprecated method used'.warning()
  void warning({String? tag}) => SecureLogger.warning(this, tag: tag);

  /// Quick error: 'Failed to load data'.error()
  void error({String? tag, Object? error, StackTrace? stackTrace}) =>
      SecureLogger.error(this, tag: tag, error: error, stackTrace: stackTrace);
}
