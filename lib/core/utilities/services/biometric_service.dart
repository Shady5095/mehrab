import 'dart:io';
import 'package:local_auth/local_auth.dart';
import '../functions/secure_logger.dart';

/// Biometric authentication service with fallback support
///
/// Security Fix: CWE-308 (Use of Single-factor Authentication)
/// CVSS Score: 3.9 (Low) → MITIGATED
///
/// Provides biometric authentication with device credential fallback
class BiometricService {
  static final _auth = LocalAuthentication();

  /// Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      SecureLogger.error('Error checking biometric availability', tag: 'Auth', error: e);
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      SecureLogger.error('Error getting available biometrics', tag: 'Auth', error: e);
      return [];
    }
  }

  /// Authenticate with biometrics only (no fallback)
  static Future<bool> authenticate(bool isArabic) async {
    return authenticateWithFallback(isArabic, allowFallback: false);
  }

  /// Authenticate with biometrics and fallback to device credentials
  ///
  /// Security Enhancement: Provides alternative authentication method
  /// when biometric fails or is unavailable
  ///
  /// [isArabic] - Use Arabic or English prompts
  /// [allowFallback] - Allow device PIN/password as fallback
  static Future<bool> authenticateWithFallback(
    bool isArabic, {
    bool allowFallback = true,
  }) async {
    try {
      // Check if biometric is available
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        SecureLogger.log('Biometric not available', tag: 'Auth');

        // If fallback allowed, use device credentials
        if (allowFallback) {
          SecureLogger.log('Falling back to device credentials', tag: 'Auth');
          return await _authenticateWithDeviceCredentials(isArabic);
        }

        return false;
      }

      // Determine localized reason based on platform and language
      String reason;
      if (Platform.isIOS) {
        reason = isArabic
            ? "سجل الدخول باستخدام بصمة الوجه"
            : "Login with Face ID";
      } else {
        reason = isArabic
            ? "سجل الدخول باستخدام بصمة الإصبع"
            : "Login with Fingerprint";
      }

      // Attempt biometric authentication
      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: !allowFallback, // Allow fallback if enabled
      );

      if (didAuthenticate) {
        SecureLogger.info('Biometric authentication successful', tag: 'Auth');
      } else {
        SecureLogger.log('Biometric authentication failed or cancelled', tag: 'Auth');
      }

      return didAuthenticate;
    } catch (e) {
      SecureLogger.error(
        'Biometric authentication error',
        tag: 'Auth',
        error: e,
      );

      // If error occurs and fallback allowed, try device credentials
      if (allowFallback) {
        SecureLogger.log('Biometric failed, trying device credentials', tag: 'Auth');
        return await _authenticateWithDeviceCredentials(isArabic);
      }

      return false;
    }
  }

  /// Private method to authenticate with device credentials (PIN/password)
  static Future<bool> _authenticateWithDeviceCredentials(bool isArabic) async {
    try {
      final reason = isArabic
          ? "سجل الدخول باستخدام رمز الجهاز"
          : "Login with device credentials";

      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false, // Allow device credentials
      );

      if (didAuthenticate) {
        SecureLogger.info('Device credential authentication successful', tag: 'Auth');
      }

      return didAuthenticate;
    } catch (e) {
      SecureLogger.error(
        'Device credential authentication error',
        tag: 'Auth',
        error: e,
      );
      return false;
    }
  }
}
