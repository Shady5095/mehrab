import 'package:firebase_auth/firebase_auth.dart';
import 'secure_cache_service.dart';
import '../functions/jwt_utils.dart';

/// Service for managing Firebase authentication tokens
class TokenService {
  /// Get a valid Firebase ID token, using cache when possible and refreshing if expired
  static Future<String?> getValidToken() async {
    try {
      // First try to get from cache
      String? cachedToken = await SecureCacheService.getToken();
      
      // If we have a cached token, check if it's still valid
      if (cachedToken != null && !JwtUtils.isTokenExpired(cachedToken)) {
        return cachedToken;
      }

      // Token is expired or missing, get fresh from Firebase
      String? freshToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      
      // If fresh token is obtained, cache it
      if (freshToken != null) {
        await SecureCacheService.setToken(freshToken);
      }

      return freshToken;
    } catch (e) {
      // If anything fails, try to get fresh token directly
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    }
  }

  /// Force refresh token from Firebase and update cache
  static Future<String?> refreshToken() async {
    try {
      final freshToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (freshToken != null) {
        await SecureCacheService.setToken(freshToken);
      }
      return freshToken;
    } catch (e) {
      return null;
    }
  }

  /// Clear cached token
  static Future<void> clearToken() async {
    await SecureCacheService.removeToken();
  }
}