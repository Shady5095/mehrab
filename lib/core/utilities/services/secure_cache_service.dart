import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'cache_service.dart';
import '../resources/constants.dart';
import '../functions/secure_logger.dart';

/// Secure cache service for sensitive data
/// Migrates sensitive data from SharedPreferences to FlutterSecureStorage
///
/// Security Fix: CWE-311 (Missing Encryption of Sensitive Data)
/// CVSS Score: 5.9 (Medium)
///
/// This service provides encrypted storage for:
/// - Authentication tokens
/// - User IDs
/// - Firebase UIDs
/// - API base URLs (may contain sensitive info)
/// - User photos (may contain PII)
///
/// Security enhancements:
/// - Device-specific encryption keys
/// - Data only accessible when device unlocked
/// - Automatic migration from insecure storage
/// - Memory cache cleared on logout
class SecureCacheService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      // resetOnError: Reset data on error (useful for migration)
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      // Data only accessible when device is unlocked
      // and only on this specific device (not synced to iCloud)
      accessibility: KeychainAccessibility.unlocked_this_device,
      // Prevent sync to iCloud
      synchronizable: false,
    ),
  );

  // Storage keys
  static const String _keyToken = 'secure_token';
  static const String _keyUserId = 'secure_user_id';
  static const String _keyUid = 'secure_uid';
  static const String _keyBaseUrl = 'secure_base_url';
  static const String _keyUserRole = 'secure_user_role';
  static const String _keyUserPhoto = 'secure_user_photo';
  static const String _keyMigrationCompleted = 'migration_completed';

  /// Initialize and migrate data from SharedPreferences
  static Future<void> init() async {
    // Check if migration already completed
    final migrationCompleted = await _storage.read(key: _keyMigrationCompleted);
    if (migrationCompleted == 'true') {
      // Migration already done, just load data to memory
      await _loadToMemory();
      return;
    }

    // Perform one-time migration
    await _migrateFromSharedPreferences();

    // Mark migration as completed
    await _storage.write(key: _keyMigrationCompleted, value: 'true');
  }

  /// Load all secure data to memory cache for performance
  static Future<void> _loadToMemory() async {
    await Future.wait([
      getToken(),
      getUserId(),
      getUid(),
      getBaseUrl(),
      getUserRole(),
      getUserPhoto(),
    ]);
  }

  /// Migrate sensitive data from SharedPreferences to secure storage
  static Future<void> _migrateFromSharedPreferences() async {
    try {
      // Migrate token
      final token = CacheService.getData(key: AppConstants.token);
      if (token != null && token is String && token.isNotEmpty) {
        await setToken(token);
        await CacheService.removeData(key: AppConstants.token);
      }

      // Migrate user ID
      final userId = CacheService.getData(key: AppConstants.userId);
      if (userId != null && userId is String && userId.isNotEmpty) {
        await setUserId(userId);
        await CacheService.removeData(key: AppConstants.userId);
      }

      // Migrate UID
      final uid = CacheService.getData(key: AppConstants.uid);
      if (uid != null && uid is String && uid.isNotEmpty) {
        await setUid(uid);
        await CacheService.removeData(key: AppConstants.uid);
      }

      // Migrate base URL
      final baseUrl = CacheService.getData(key: AppConstants.baseUrl);
      if (baseUrl != null && baseUrl is String && baseUrl.isNotEmpty) {
        await setBaseUrl(baseUrl);
        await CacheService.removeData(key: AppConstants.baseUrl);
      }

      // Migrate user role
      final userRole = CacheService.getData(key: AppConstants.userRole);
      if (userRole != null && userRole is String && userRole.isNotEmpty) {
        await setUserRole(userRole);
        await CacheService.removeData(key: AppConstants.userRole);
      }

      // Migrate user photo
      final userPhoto = CacheService.getData(key: AppConstants.userPhoto);
      if (userPhoto != null && userPhoto is String && userPhoto.isNotEmpty) {
        await setUserPhoto(userPhoto);
        await CacheService.removeData(key: AppConstants.userPhoto);
      }

      SecureLogger.info('Secure storage migration completed', tag: 'SecureCacheService');
    } catch (e) {
      // Migration errors should not crash the app
      // Log error without exposing sensitive data
      assert(() {
        SecureLogger.error('Migration failed - please check storage permissions',
          tag: 'SecureCacheService',
          error: e);
        return true;
      }());
    }
  }

  // ========== Token ==========

  /// Save authentication token securely
  static Future<void> setToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    CacheService.token = token; // Keep in memory for quick access
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    // Check memory cache first
    if (CacheService.token != null) {
      return CacheService.token;
    }

    // Load from secure storage
    final token = await _storage.read(key: _keyToken);
    if (token != null) {
      CacheService.token = token; // Cache in memory
    }
    return token;
  }

  /// Remove authentication token
  static Future<void> removeToken() async {
    await _storage.delete(key: _keyToken);
    CacheService.token = null;
  }

  // ========== User ID ==========

  /// Save user ID securely
  static Future<void> setUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
    CacheService.userId = userId;
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    if (CacheService.userId != null) {
      return CacheService.userId;
    }

    final userId = await _storage.read(key: _keyUserId);
    if (userId != null) {
      CacheService.userId = userId;
    }
    return userId;
  }

  /// Remove user ID
  static Future<void> removeUserId() async {
    await _storage.delete(key: _keyUserId);
    CacheService.userId = null;
  }

  // ========== Firebase UID ==========

  /// Save Firebase UID securely
  static Future<void> setUid(String uid) async {
    await _storage.write(key: _keyUid, value: uid);
    CacheService.uid = uid;
  }

  /// Get Firebase UID
  static Future<String?> getUid() async {
    if (CacheService.uid != null) {
      return CacheService.uid;
    }

    final uid = await _storage.read(key: _keyUid);
    if (uid != null) {
      CacheService.uid = uid;
    }
    return uid;
  }

  /// Remove Firebase UID
  static Future<void> removeUid() async {
    await _storage.delete(key: _keyUid);
    CacheService.uid = null;
  }

  // ========== Base URL ==========

  /// Save API base URL securely
  static Future<void> setBaseUrl(String baseUrl) async {
    await _storage.write(key: _keyBaseUrl, value: baseUrl);
    CacheService.baseUrl = baseUrl;
  }

  /// Get API base URL
  static Future<String?> getBaseUrl() async {
    if (CacheService.baseUrl != null) {
      return CacheService.baseUrl;
    }

    final baseUrl = await _storage.read(key: _keyBaseUrl);
    if (baseUrl != null) {
      CacheService.baseUrl = baseUrl;
    }
    return baseUrl;
  }

  /// Remove API base URL
  static Future<void> removeBaseUrl() async {
    await _storage.delete(key: _keyBaseUrl);
    CacheService.baseUrl = null;
  }

  // ========== User Role ==========

  /// Save user role securely
  static Future<void> setUserRole(String userRole) async {
    await _storage.write(key: _keyUserRole, value: userRole);
    CacheService.userRole = userRole;
  }

  /// Get user role
  static Future<String?> getUserRole() async {
    if (CacheService.userRole != null) {
      return CacheService.userRole;
    }

    final userRole = await _storage.read(key: _keyUserRole);
    if (userRole != null) {
      CacheService.userRole = userRole;
    }
    return userRole;
  }

  /// Remove user role
  static Future<void> removeUserRole() async {
    await _storage.delete(key: _keyUserRole);
    CacheService.userRole = null;
  }

  // ========== User Photo ==========

  /// Save user photo URL securely
  static Future<void> setUserPhoto(String userPhoto) async {
    await _storage.write(key: _keyUserPhoto, value: userPhoto);
    CacheService.userPhoto = userPhoto;
  }

  /// Get user photo URL
  static Future<String?> getUserPhoto() async {
    if (CacheService.userPhoto != null) {
      return CacheService.userPhoto;
    }

    final userPhoto = await _storage.read(key: _keyUserPhoto);
    if (userPhoto != null) {
      CacheService.userPhoto = userPhoto;
    }
    return userPhoto;
  }

  /// Remove user photo URL
  static Future<void> removeUserPhoto() async {
    await _storage.delete(key: _keyUserPhoto);
    CacheService.userPhoto = null;
  }

  // ========== Bulk Operations ==========

  /// Clear all secure data (logout)
  static Future<void> clearAll() async {
    try {
      await Future.wait([
        removeToken(),
        removeUserId(),
        removeUid(),
        removeBaseUrl(),
        removeUserRole(),
        removeUserPhoto(),
      ]);

      // Also clear all memory caches
      _clearMemoryCache();

      SecureLogger.info('All secure data cleared', tag: 'SecureCacheService');
    } catch (e) {
      SecureLogger.error('Failed to clear secure data',
        tag: 'SecureCacheService',
        error: e);
    }
  }

  /// Clear all data from memory cache
  static void _clearMemoryCache() {
    CacheService.token = null;
    CacheService.userId = null;
    CacheService.uid = null;
    CacheService.baseUrl = null;
    CacheService.userRole = null;
    CacheService.userPhoto = null;
  }

  /// Check if user is logged in (has valid token)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Complete secure storage reset (use with caution)
  /// This will delete ALL secure storage data including migration flag
  static Future<void> resetSecureStorage() async {
    try {
      await _storage.deleteAll();
      _clearMemoryCache();
      SecureLogger.warning('Secure storage completely reset', tag: 'SecureCacheService');
    } catch (e) {
      SecureLogger.error('Failed to reset secure storage',
        tag: 'SecureCacheService',
        error: e);
    }
  }
}
