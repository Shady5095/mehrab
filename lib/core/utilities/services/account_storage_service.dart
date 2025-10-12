import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'saved_accounts';

  /// ✅ حفظ حساب جديد
  static Future<void> saveAccount(String email, String password) async {
    final accounts = await getAccounts();
    accounts[email] = password;

    final jsonData = jsonEncode(accounts);
    await _storage.write(key: _key, value: jsonData);
  }

  /// ✅ جلب كل الحسابات
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

  /// ✅ حذف حساب معين
  static Future<void> removeAccount(String email) async {
    final accounts = await getAccounts();
    accounts.remove(email);

    final jsonData = jsonEncode(accounts);
    await _storage.write(key: _key, value: jsonData);

  }

  /// ✅ مسح كل الحسابات (اختياري)
  static Future<void> clearAllAccounts() async {
    await _storage.delete(key: _key);
  }
}
