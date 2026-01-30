import 'dart:convert';

/// Utility functions for handling JWT tokens
class JwtUtils {
  /// Check if Firebase ID token is expired by decoding JWT
  static bool isTokenExpired(String token) {
    try {
      // JWT has 3 parts separated by '.'
      final parts = token.split('.');
      if (parts.length != 3) return true; // Invalid token format

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

      // Parse JSON
      final payloadMap = json.decode(decodedPayload);

      // Get expiration time (exp claim)
      final exp = payloadMap['exp'];
      if (exp == null) return true; // No expiration claim

      // Convert to DateTime and check if expired
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Add 5 minute buffer to account for clock skew
      final bufferTime = now.add(const Duration(minutes: 5));

      return bufferTime.isAfter(expirationDate);
    } catch (e) {
      // If we can't decode, assume it's expired to be safe
      return true;
    }
  }
}