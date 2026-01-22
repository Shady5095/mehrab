import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TurnCredentialService {
  final String serverUrl;
  final Dio _dio;

  TurnCredentialService({
    required this.serverUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>?> fetchCredentials(String authToken) async {
    try {
      debugPrint('TURN: Fetching credentials from $serverUrl');

      final response = await _dio.get(
        '$serverUrl/api/turn-credentials',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('TURN: Credentials fetched successfully');
        return Map<String, dynamic>.from(response.data);
      }

      debugPrint('TURN: Failed to fetch credentials: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      debugPrint('TURN: Error fetching credentials: ${e.message}');
      return _getDefaultIceServers();
    } catch (e) {
      debugPrint('TURN: Unexpected error: $e');
      return _getDefaultIceServers();
    }
  }

  Map<String, dynamic> _getDefaultIceServers() {
    return {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
      ],
    };
  }
}
