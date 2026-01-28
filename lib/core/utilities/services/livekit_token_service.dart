import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service to fetch LiveKit access tokens from the backend API
class LiveKitTokenService {
  final String apiUrl;
  final Dio _dio;

  LiveKitTokenService({
    required this.apiUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// Fetches a LiveKit access token from the backend
  ///
  /// [roomName] - The room identifier (typically the call ID)
  /// [participantName] - The display name of the participant
  /// [authToken] - Firebase auth token for authentication
  ///
  /// Returns the LiveKit access token string, or null if the request fails
  Future<String?> fetchToken({
    required String roomName,
    required String participantName,
    required String authToken,
  }) async {
    try {
      final response = await _dio.post(
        '$apiUrl/api/livekit/token',
        data: {
          'roomName': roomName,
          'participantName': participantName,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          debugPrint('LiveKitTokenService: Token fetched successfully');
          return token;
        }
      }

      debugPrint('LiveKitTokenService: Invalid response - ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      debugPrint('LiveKitTokenService: DioException - ${e.message}');
      if (e.response != null) {
        debugPrint('LiveKitTokenService: Response - ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('LiveKitTokenService: Error - $e');
      return null;
    }
  }

  void dispose() {
    _dio.close();
  }
}
