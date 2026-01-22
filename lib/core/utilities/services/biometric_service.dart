import 'dart:io';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate(bool isArabic) async {
    final canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;

    // تحديد النص بناءً على اللغة و المنصة
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

    final didAuthenticate = await _auth.authenticate(
      localizedReason: reason,
      biometricOnly: true,
      persistAcrossBackgrounding: true, // يفضل في Android عشان يفضل شغال لو رجع من الخلفية
    );

    return didAuthenticate;
  }
}
