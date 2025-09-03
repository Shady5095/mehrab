import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static late SharedPreferences _sharedPreferences;
  static String? token;
  static String? userId;
  static String? userPhoto;
  static String? baseUrl;
  static bool? isEnglishCacheValue;
  static int? themeMode;
  static String? userRole;
  static String? schoolImage;
  static bool? isParentSelectChild;
  static String? uid;

  static bool? isShowGrades;

  static int? selectedChild;

  static int? runningTask;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static dynamic getData({required String key}) {
    return _sharedPreferences.get(key);
  }

  static Future<bool?> setData({
    required String key,
    required dynamic value,
  }) async {
    if (value is bool) {
      return _sharedPreferences.setBool(key, value);
    }
    if (value is String) {
      return _sharedPreferences.setString(key, value);
    }
    if (value is int) {
      return _sharedPreferences.setInt(key, value);
    }
    if (value is double) {
      return _sharedPreferences.setDouble(key, value);
    }
    return null;
  }

  static Future<bool?> removeData({required String key}) async {
    return _sharedPreferences.remove(key);
  }

  static Future<bool?> clear() async {
    return _sharedPreferences.clear();
  }
}
