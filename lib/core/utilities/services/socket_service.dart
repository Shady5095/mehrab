import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../functions/secure_logger.dart';

class SocketService {
  io.Socket? _socket;
  bool _isConnected = false;
  String? _currentRoomId;
  String? _pendingRejoinRoomId; // Room to rejoin after reconnection

  // Connection callbacks
  Function()? onConnected;
  Function()? onDisconnected;
  Function()? onReconnected; // Called when socket reconnects (not first connect)
  Function(String error)? onError;

  // Room callbacks
  Function(String callId, List<Map<String, dynamic>> participants)? onRoomJoined;
  Function(String odId, String socketId)? onUserJoined;
  Function(String odId, String socketId)? onUserLeft;

  // Signaling callbacks
  Function(RTCSessionDescription offer, String fromSocketId, String fromUid)? onOfferReceived;
  Function(RTCSessionDescription answer, String fromSocketId, String fromUid)? onAnswerReceived;
  Function(RTCIceCandidate candidate, String fromSocketId)? onIceCandidateReceived;
  Function(bool enabled, String fromSocketId)? onVideoStateChanged;

  bool get isConnected => _isConnected;
  String? get currentRoomId => _currentRoomId;
  String? get socketId => _socket?.id;

  /// Connect to WebRTC signaling server with optional authentication
  ///
  /// [serverUrl] - WebRTC signaling server URL (should use HTTPS)
  /// [authToken] - Optional Firebase ID token for authentication.
  ///               If not provided, server will assign a guest ID.
  Future<void> connect(String serverUrl, [String? authToken]) async {
    if (_socket != null) {
      await disconnect();
    }

    // SECURITY: Validate server URL uses HTTPS
    if (!serverUrl.startsWith('https://') && !serverUrl.startsWith('wss://')) {
      SecureLogger.warning(
        'Insecure WebRTC server URL detected - should use HTTPS/WSS',
        tag: 'WebRTC',
      );
    }

    SecureLogger.webrtc('Connecting to signaling server', tag: 'WebRTC');

    final optionBuilder = io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000);

    // Only set auth if token is provided
    if (authToken != null && authToken.isNotEmpty) {
      optionBuilder.setAuth({
        'token': authToken,
        'type': 'firebase',
      });
      SecureLogger.webrtc('Connecting with authentication');
    } else {
      SecureLogger.webrtc('Connecting as guest (no auth token)');
    }

    _socket = io.io(serverUrl, optionBuilder.build());

    _setupEventListeners();
  }

  bool _hasConnectedOnce = false;

  void _setupEventListeners() {
    _socket!.onConnect((_) {
      SecureLogger.webrtc('Connected (id: ${_socket!.id})');
      _isConnected = true;

      if (_hasConnectedOnce) {
        // This is a reconnection
        SecureLogger.webrtc('Socket reconnected');

        // Rejoin room if we were in one
        if (_pendingRejoinRoomId != null) {
          SecureLogger.webrtc('Rejoining room after reconnection: $_pendingRejoinRoomId');
          _socket!.emit('join-room', {'callId': _pendingRejoinRoomId});
        }

        onReconnected?.call();
      } else {
        _hasConnectedOnce = true;
        onConnected?.call();
      }
    });

    _socket!.onDisconnect((_) {
      SecureLogger.webrtc('Disconnected');
      _isConnected = false;

      // Save room ID for potential rejoin (don't clear it)
      if (_currentRoomId != null) {
        _pendingRejoinRoomId = _currentRoomId;
        SecureLogger.webrtc('Saved room for rejoin: $_pendingRejoinRoomId');
      }
      _currentRoomId = null;

      onDisconnected?.call();
    });

    _socket!.onConnectError((error) {
      SecureLogger.webrtc('Connection error: $error');
      final userMessage = _categorizeConnectionError(error);
      onError?.call(userMessage);
    });

    _socket!.onError((error) {
      SecureLogger.webrtc('Error: $error');
      final userMessage = _categorizeSocketError(error);
      onError?.call(userMessage);
    });

    _socket!.on('room-joined', (data) {
      SecureLogger.webrtc('Room joined: ${data['callId']}');
      _currentRoomId = data['callId'];

      final participants = (data['participants'] as List?)
              ?.map((p) => Map<String, dynamic>.from(p as Map))
              .toList() ??
          [];

      onRoomJoined?.call(data['callId'], participants);
    });

    _socket!.on('user-joined', (data) {
      SecureLogger.webrtc('User joined: ${data['odId']}');
      onUserJoined?.call(data['odId'], data['socketId']);
    });

    _socket!.on('user-left', (data) {
      SecureLogger.webrtc('User left: ${data['odId']}');
      onUserLeft?.call(data['odId'], data['socketId']);
    });

    _socket!.on('offer', (data) {
      try {
        if (data == null || data['offer'] == null) {
          SecureLogger.webrtc('Invalid offer data received');
          return;
        }
        SecureLogger.webrtc('Offer received from ${data['from']}');
        final offerData = data['offer'];
        if (offerData['sdp'] == null || offerData['type'] == null) {
          SecureLogger.webrtc('Missing SDP or type in offer');
          return;
        }
        final offer = RTCSessionDescription(
          offerData['sdp'] as String,
          offerData['type'] as String,
        );
        onOfferReceived?.call(
          offer,
          data['from'] as String? ?? '',
          data['fromUid'] as String? ?? '',
        );
      } catch (e) {
        SecureLogger.webrtc('Error parsing offer: $e');
      }
    });

    _socket!.on('answer', (data) {
      try {
        if (data == null || data['answer'] == null) {
          SecureLogger.webrtc('Invalid answer data received');
          return;
        }
        SecureLogger.webrtc('Answer received from ${data['from']}');
        final answerData = data['answer'];
        if (answerData['sdp'] == null || answerData['type'] == null) {
          SecureLogger.webrtc('Missing SDP or type in answer');
          return;
        }
        final answer = RTCSessionDescription(
          answerData['sdp'] as String,
          answerData['type'] as String,
        );
        onAnswerReceived?.call(
          answer,
          data['from'] as String? ?? '',
          data['fromUid'] as String? ?? '',
        );
      } catch (e) {
        SecureLogger.webrtc('Error parsing answer: $e');
      }
    });

    _socket!.on('ice-candidate', (data) {
      try {
        if (data == null || data['candidate'] == null) {
          SecureLogger.webrtc('Invalid ICE candidate data received');
          return;
        }
        SecureLogger.webrtc('ICE candidate received from ${data['from']}');
        final candidateData = data['candidate'];
        final candidate = RTCIceCandidate(
          candidateData['candidate'] as String?,
          candidateData['sdpMid'] as String?,
          candidateData['sdpMLineIndex'] as int?,
        );
        onIceCandidateReceived?.call(candidate, data['from'] as String? ?? '');
      } catch (e) {
        SecureLogger.webrtc('Error parsing ICE candidate: $e');
      }
    });

    _socket!.on('video-state', (data) {
      SecureLogger.webrtc('Video state received from ${data['from']}: ${data['enabled']}');
      onVideoStateChanged?.call(data['enabled'] as bool, data['from'] as String);
    });
  }

  void joinRoom(String callId) {
    if (!_isConnected || _socket == null) {
      SecureLogger.webrtc('Cannot join room - not connected');
      onError?.call('Not connected to server');
      return;
    }

    SecureLogger.webrtc('Joining room $callId');
    _pendingRejoinRoomId = callId; // Save for potential reconnection
    _socket!.emit('join-room', {'callId': callId});
  }

  void leaveRoom(String callId) {
    if (!_isConnected || _socket == null) {
      return;
    }

    SecureLogger.webrtc('Leaving room $callId');
    _socket!.emit('leave-room', {'callId': callId});
    _currentRoomId = null;
    _pendingRejoinRoomId = null; // Clear the pending rejoin
  }

  void sendOffer(RTCSessionDescription offer, String toSocketId) {
    if (!_isConnected || _socket == null) {
      SecureLogger.webrtc('Cannot send offer - not connected');
      return;
    }

    SecureLogger.webrtc('Sending offer to $toSocketId');
    _socket!.emit('offer', {
      'offer': {
        'sdp': offer.sdp,
        'type': offer.type,
      },
      'to': toSocketId,
    });
  }

  void sendAnswer(RTCSessionDescription answer, String toSocketId) {
    if (!_isConnected || _socket == null) {
      SecureLogger.webrtc('Cannot send answer - not connected');
      return;
    }

    SecureLogger.webrtc('Sending answer to $toSocketId');
    _socket!.emit('answer', {
      'answer': {
        'sdp': answer.sdp,
        'type': answer.type,
      },
      'to': toSocketId,
    });
  }

  void sendIceCandidate(RTCIceCandidate candidate, String toSocketId) {
    if (!_isConnected || _socket == null) {
      return;
    }

    _socket!.emit('ice-candidate', {
      'candidate': {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      },
      'to': toSocketId,
    });
  }

  void sendVideoState(bool enabled, String toSocketId) {
    if (!_isConnected || _socket == null) {
      return;
    }

    SecureLogger.webrtc('Sending video state ($enabled) to $toSocketId');
    _socket!.emit('video-state', {
      'enabled': enabled,
      'to': toSocketId,
    });
  }

  Future<Map<String, dynamic>?> getIceConfig() async {
    if (!_isConnected || _socket == null) {
      SecureLogger.webrtc('Cannot get ICE config - not connected');
      return null;
    }

    final completer = Completer<Map<String, dynamic>?>();

    _socket!.emitWithAck('get-ice-config', null, ack: (data) {
      if (data != null) {
        completer.complete(Map<String, dynamic>.from(data as Map));
      } else {
        completer.complete(null);
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  }

  Future<void> disconnect() async {
    if (_currentRoomId != null) {
      leaveRoom(_currentRoomId!);
    }

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _currentRoomId = null;
    _pendingRejoinRoomId = null;
    _hasConnectedOnce = false;

    SecureLogger.webrtc('Disconnected and disposed');
  }

  void dispose() {
    disconnect();
  }

  /// Categorizes connection errors into user-friendly messages
  String _categorizeConnectionError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('auth') ||
        errorStr.contains('401') ||
        errorStr.contains('403') ||
        errorStr.contains('unauthorized')) {
      return 'فشل التحقق من الهوية. الرجاء تسجيل الدخول مرة أخرى.';
    }

    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.';
    }

    if (errorStr.contains('econnrefused') ||
        errorStr.contains('connection refused')) {
      return 'لا يمكن الوصول إلى الخادم. الرجاء المحاولة لاحقاً.';
    }

    if (errorStr.contains('ssl') ||
        errorStr.contains('certificate') ||
        errorStr.contains('tls')) {
      return 'خطأ في الاتصال الآمن. الرجاء المحاولة لاحقاً.';
    }

    if (errorStr.contains('network') ||
        errorStr.contains('internet') ||
        errorStr.contains('offline')) {
      return 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك.';
    }

    if (errorStr.contains('dns') || errorStr.contains('host')) {
      return 'تعذر الوصول إلى الخادم. تحقق من اتصالك بالإنترنت.';
    }

    return 'حدث خطأ اثناء الاتصال بالسيرفر. الرجاء المحاولة مرة أخرى لاحقاً.';
  }

  /// Categorizes socket errors into user-friendly messages
  String _categorizeSocketError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('disconnect')) {
      return 'انقطع الاتصال. جاري إعادة المحاولة...';
    }

    if (errorStr.contains('reconnect')) {
      return 'جاري إعادة الاتصال...';
    }

    if (errorStr.contains('transport')) {
      return 'خطأ في الاتصال. جاري المحاولة مرة أخرى...';
    }

    return 'حدث خطأ في الاتصال. الرجاء المحاولة مرة أخرى.';
  }
}
