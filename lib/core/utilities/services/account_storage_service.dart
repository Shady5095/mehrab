import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'saved_accounts';

  static Future<void> saveAccount(String email, String password) async {
    final accounts = await getAccounts();
    accounts[email] = password;
    await _storage.write(key: _key, value: accounts.toString());
  }

  static Future<Map<String, String>> getAccounts() async {
    final data = await _storage.read(key: _key);
    if (data == null) return {};
    final parsed = data
        .substring(1, data.length - 1) // remove {}
        .split(', ')
        .map((e) => e.split(': '))
        .map((e) => MapEntry(e[0], e[1]))
        .toList();
    return Map.fromEntries(parsed);
  }

  static Future<void> removeAccount(String email) async {
    final accounts = await getAccounts();
    accounts.remove(email);
    await _storage.write(key: _key, value: accounts.toString());
  }
}
