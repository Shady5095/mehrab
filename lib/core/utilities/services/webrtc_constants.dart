import '../../config/app_config.dart';

/// WebRTC Configuration Constants
/// Now uses AppConfig for environment-based configuration
///
/// Security Fix: CWE-547 (Hard-coded Security-relevant Constants)
/// Configuration can now be changed via build-time flags without code changes
///
/// Usage:
/// - Default (production): Uses hardcoded production URLs
/// - Custom build: flutter build --dart-define=SIGNALING_SERVER_URL=https://custom.com
/// - Development: flutter run --dart-define=ENVIRONMENT=development --dart-define=DEV_SIGNALING_URL=http://localhost:3000
@Deprecated('Use AppConfig directly instead. Will be removed in next major version.')
class WebRTCConstants {
  // Signaling server URL (now from AppConfig)
  static String get signalingServerUrl => AppConfig.signalingServerUrl;

  // TURN server domain (now from AppConfig)
  static String get turnDomain => AppConfig.turnDomain;
}
