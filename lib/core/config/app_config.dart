import 'package:flutter/foundation.dart';

/// Application configuration
/// Centralizes all environment-specific settings
///
/// This addresses CWE-547 (Use of Hard-coded, Security-relevant Constants)
/// by allowing configuration changes without code updates
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  /// Environment type
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  /// Check if running in development mode
  static bool get isDevelopment => _environment == 'development';

  /// Check if running in staging mode
  static bool get isStaging => _environment == 'staging';

  /// Check if running in production mode
  static bool get isProduction => _environment == 'production';

  // ========== WebRTC Configuration ==========

  /// WebRTC Signaling Server URL
  /// Set via --dart-define=SIGNALING_SERVER_URL=https://your-server.com
  static const String _signalingServerUrl = String.fromEnvironment(
    'SIGNALING_SERVER_URL',
    defaultValue: 'https://signal.ahmedhany.dev',
  );

  static String get signalingServerUrl {
    if (kDebugMode && isDevelopment) {
      // Can override for local development
      return const String.fromEnvironment(
        'DEV_SIGNALING_URL',
        defaultValue: _signalingServerUrl,
      );
    }
    return _signalingServerUrl;
  }

  /// LiveKit Server URL
  /// Set via --dart-define=LIVEKIT_URL=https://livekit.your-server.com
  static const String _livekitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: 'https://livekit.mehrab-alquran.com/',
  );

  static String get livekitUrl => _livekitUrl;

  // ========== API Configuration ==========

  /// API Base URL
  /// Set via --dart-define=API_BASE_URL=https://api.your-server.com
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '', // Should be configured via dart-define
  );

  static String get apiBaseUrl => _apiBaseUrl;

  /// API Timeout (in seconds)
  static const int apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 60,
  );

  // ========== Feature Flags ==========

  /// Enable debug logging
  static bool get enableDebugLogging => kDebugMode || isDevelopment;

  /// Enable analytics
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  /// Enable crash reporting
  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: true,
  );

  // ========== Build Information ==========

  /// App version (set during build)
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '2.6.0',
  );

  /// Build number (set during build)
  static const int buildNumber = int.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: 48,
  );

  // ========== Development Helpers ==========

  /// Print current configuration (debug only)
  static void printConfig() {
    if (kDebugMode) {
      debugPrint('=== App Configuration ===');
      debugPrint('Environment: $_environment');
      debugPrint('Signaling Server: $signalingServerUrl');
      debugPrint('LiveKit URL: $livekitUrl');
      debugPrint('API Base URL: $apiBaseUrl');
      debugPrint('API Timeout: $apiTimeout seconds');
      debugPrint('Debug Logging: $enableDebugLogging');
      debugPrint('Analytics: $enableAnalytics');
      debugPrint('Crash Reporting: $enableCrashReporting');
      debugPrint('App Version: $appVersion');
      debugPrint('Build Number: $buildNumber');
      debugPrint('========================');
    }
  }
}
