import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;
  bool _isConnected = false;
  String? _currentRoomId;

  // Connection callbacks
  Function()? onConnected;
  Function()? onDisconnected;
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

  Future<void> connect(String serverUrl, String authToken) async {
    if (_socket != null) {
      await disconnect();
    }

    debugPrint('Socket: Connecting to $serverUrl');

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': authToken})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    _setupEventListeners();
  }

  void _setupEventListeners() {
    _socket!.onConnect((_) {
      debugPrint('Socket: Connected (id: ${_socket!.id})');
      _isConnected = true;
      onConnected?.call();
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket: Disconnected');
      _isConnected = false;
      _currentRoomId = null;
      onDisconnected?.call();
    });

    _socket!.onConnectError((error) {
      debugPrint('Socket: Connection error: $error');
      onError?.call('Connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('Socket: Error: $error');
      onError?.call('Socket error: $error');
    });

    _socket!.on('room-joined', (data) {
      debugPrint('Socket: Room joined: ${data['callId']}');
      _currentRoomId = data['callId'];

      final participants = (data['participants'] as List?)
              ?.map((p) => Map<String, dynamic>.from(p as Map))
              .toList() ??
          [];

      onRoomJoined?.call(data['callId'], participants);
    });

    _socket!.on('user-joined', (data) {
      debugPrint('Socket: User joined: ${data['odId']}');
      onUserJoined?.call(data['odId'], data['socketId']);
    });

    _socket!.on('user-left', (data) {
      debugPrint('Socket: User left: ${data['odId']}');
      onUserLeft?.call(data['odId'], data['socketId']);
    });

    _socket!.on('offer', (data) {
      debugPrint('Socket: Offer received from ${data['from']}');
      final offer = RTCSessionDescription(
        data['offer']['sdp'],
        data['offer']['type'],
      );
      onOfferReceived?.call(offer, data['from'], data['fromUid']);
    });

    _socket!.on('answer', (data) {
      debugPrint('Socket: Answer received from ${data['from']}');
      final answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );
      onAnswerReceived?.call(answer, data['from'], data['fromUid']);
    });

    _socket!.on('ice-candidate', (data) {
      debugPrint('Socket: ICE candidate received from ${data['from']}');
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      onIceCandidateReceived?.call(candidate, data['from']);
    });

    _socket!.on('video-state', (data) {
      debugPrint('Socket: Video state received from ${data['from']}: ${data['enabled']}');
      onVideoStateChanged?.call(data['enabled'] as bool, data['from'] as String);
    });
  }

  void joinRoom(String callId) {
    if (!_isConnected || _socket == null) {
      debugPrint('Socket: Cannot join room - not connected');
      onError?.call('Not connected to server');
      return;
    }

    debugPrint('Socket: Joining room $callId');
    _socket!.emit('join-room', {'callId': callId});
  }

  void leaveRoom(String callId) {
    if (!_isConnected || _socket == null) {
      return;
    }

    debugPrint('Socket: Leaving room $callId');
    _socket!.emit('leave-room', {'callId': callId});
    _currentRoomId = null;
  }

  void sendOffer(RTCSessionDescription offer, String toSocketId) {
    if (!_isConnected || _socket == null) {
      debugPrint('Socket: Cannot send offer - not connected');
      return;
    }

    debugPrint('Socket: Sending offer to $toSocketId');
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
      debugPrint('Socket: Cannot send answer - not connected');
      return;
    }

    debugPrint('Socket: Sending answer to $toSocketId');
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

    debugPrint('Socket: Sending video state ($enabled) to $toSocketId');
    _socket!.emit('video-state', {
      'enabled': enabled,
      'to': toSocketId,
    });
  }

  Future<Map<String, dynamic>?> getIceConfig() async {
    if (!_isConnected || _socket == null) {
      debugPrint('Socket: Cannot get ICE config - not connected');
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

    debugPrint('Socket: Disconnected and disposed');
  }

  void dispose() {
    disconnect();
  }
}
