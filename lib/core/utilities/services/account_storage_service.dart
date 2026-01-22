import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ⚠️ SECURITY WARNING: This class previously stored passwords in plain text
/// Password storage has been DEPRECATED for security reasons (CWE-256)
///
/// NEVER store user passwords - use token-based authentication instead:
/// - Firebase Auth handles session management automatically
/// - Use biometric authentication for re-authentication
/// - Store refresh tokens (if needed) instead of passwords
///
/// This class is kept only for backward compatibility to:
/// 1. Retrieve legacy stored accounts (for migration)
/// 2. Clear old stored passwords
///
/// DO NOT use saveAccount() - it will throw an error
class AccountStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'saved_accounts';

  /// ❌ DEPRECATED: DO NOT USE - Password storage is a security vulnerability
  /// This method now throws an error to prevent password storage
  ///
  /// Security Issue: CWE-256 (Plaintext Storage of a Password)
  /// CVSS Score: 8.1 (High)
  ///
  /// @deprecated Use Firebase Authentication and biometric re-authentication instead
  @Deprecated('Password storage is insecure. Use Firebase Auth session management.')
  static Future<void> saveAccount(String email, String password) async {
    throw UnsupportedError(
      'Password storage has been disabled for security reasons. '
      'Please use Firebase Authentication and biometric authentication instead.',
    );
  }

  /// ⚠️ DEPRECATED: Only for retrieving legacy accounts for migration
  /// Returns stored accounts (if any exist from older app versions)
  ///
  /// @deprecated This method will be removed in future versions
  @Deprecated('Password storage has been removed. This is only for legacy migration.')
  static Future<Map<String, String>> getAccounts() async {
    final data = await _storage.read(key: _key);
    if (data == null || data.isEmpty) return {};

    try {
      final decoded = jsonDecode(data);
      return Map<String, String>.from(decoded);
    } catch (e) {
      return {};
    }
  }

  /// ⚠️ DEPRECATED: Only for removing legacy stored accounts
  ///
  /// @deprecated This method will be removed in future versions
  @Deprecated('Password storage has been removed. This is only for legacy cleanup.')
  static Future<void> removeAccount(String email) async {
    final accounts = await getAccounts();
    accounts.remove(email);

    if (accounts.isEmpty) {
      await _storage.delete(key: _key);
    } else {
      final jsonData = jsonEncode(accounts);
      await _storage.write(key: _key, value: jsonData);
    }
  }

  /// ✅ MIGRATION HELPER: Clear all legacy stored passwords
  /// Call this method once during app startup to remove old stored passwords
  ///
  /// This is the ONLY recommended method from this class
  static Future<void> clearAllAccounts() async {
    await _storage.delete(key: _key);
  }

  /// ✅ Check if legacy passwords exist (for migration prompt)
  static Future<bool> hasLegacyPasswords() async {
    final data = await _storage.read(key: _key);
    return data != null && data.isNotEmpty;
  }
}
