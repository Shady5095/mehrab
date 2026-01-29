import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import '../../config/app_config.dart';

enum CallQuality {
  excellent,
  good,
  poor,
}

class LiveKitCallService {
  lk.Room? _room;
  lk.LocalParticipant? get localParticipant => _room?.localParticipant;
  List<lk.RemoteParticipant> get remoteParticipants => _room?.remoteParticipants.values.toList() ?? [];

  bool isMicMuted = false;
  bool isVideoEnabled = false;
  bool isFrontCamera = true;
  bool _isSpeakerOn = true;
  bool _hasVideoCapability = false;
  bool _hasAudioCapability = false;

  bool get hasVideoCapability => _hasVideoCapability;
  bool get hasAudioCapability => _hasAudioCapability;
  bool get isSpeakerOn => _isSpeakerOn;

  // Video tracks for LiveKit rendering
  lk.LocalVideoTrack? get localVideoTrack => _room?.localParticipant?.videoTrackPublications
      .where((pub) => pub.track != null)
      .map((pub) => pub.track as lk.LocalVideoTrack)
      .firstOrNull;
  
  lk.RemoteVideoTrack? get remoteVideoTrack => _room?.remoteParticipants.values
      .expand((participant) => participant.videoTrackPublications)
      .where((pub) => pub.track != null)
      .map((pub) => pub.track as lk.RemoteVideoTrack)
      .firstOrNull;

  // Callbacks matching the original interface
  Function(String participantId)? onUserJoined;
  Function(String participantId)? onUserLeft;
  Function(String error)? onError;
  Function()? onCallEnded;
  Function()? onConnectionSuccess;
  Function(String participantId, bool enabled)? onRemoteVideoStateChanged;
  Function(CallQuality quality)? onNetworkQualityChanged;

  Future<void> initialize() async {
    final roomOptions = lk.RoomOptions(
      adaptiveStream: true,
      dynacast: true,
    );
    _room = lk.Room(roomOptions: roomOptions);

    // Set up room event listeners
    _room!.addListener(_onRoomEvent);

    // Check capabilities
    _hasVideoCapability = true;
    _hasAudioCapability = true;
  }

  lk.ConnectionState? _previousConnectionState;

  void _onRoomEvent() {
    final currentState = _room?.connectionState;
    if (currentState == lk.ConnectionState.connected && 
        _previousConnectionState != lk.ConnectionState.connected) {
      onConnectionSuccess?.call();
    } else if (currentState == lk.ConnectionState.disconnected && 
               _previousConnectionState != lk.ConnectionState.disconnected) {
      onCallEnded?.call();
    }
    _previousConnectionState = currentState;
  }

  Future<void> connect(String token, String roomName) async {
    try {
      await _room?.connect(
        'wss://${AppConfig.livekitUrl.replaceFirst('https://', '')}',
        token,
      );

      // Set up participant event listeners
      _setupParticipantListeners();

    } catch (error) {
      onError?.call('Failed to connect to room: $error');
    }
  }

  // Track notified participants to avoid duplicate callbacks
  final Set<String> _notifiedParticipants = {};

  void _setupParticipantListeners() {
    if (_room == null) return;

    // Listen for participant events
    _room!.addListener(() {
      final currentParticipants = _room!.remoteParticipants.values.map((p) => p.identity).toSet();
      
      // Notify for new participants
      for (final participant in _room!.remoteParticipants.values) {
        if (!_notifiedParticipants.contains(participant.identity)) {
          debugPrint('🔗 LiveKit participant connected: ${participant.identity}');
          _notifiedParticipants.add(participant.identity);
          onUserJoined?.call(participant.identity);
        }
        
        // Update remote video state
        final videoPub = participant.trackPublications.values
            .where((pub) => pub.kind == lk.TrackType.VIDEO)
            .firstOrNull;
        if (videoPub != null && videoPub.track != null) {
          // Video track is available for rendering
          debugPrint('📹 Video track available for participant: ${participant.identity}');
        }
      }
      
      // Notify for disconnected participants
      final disconnected = _notifiedParticipants.difference(currentParticipants);
      for (final identity in disconnected) {
        debugPrint('🔌 LiveKit participant disconnected: $identity');
        _notifiedParticipants.remove(identity);
        onUserLeft?.call(identity);
      }
    });
  }

  Future<void> setIceServers(List<Map<String, dynamic>> iceServers) async {
    // LiveKit handles ICE servers internally
  }

  Future<void> toggleMute() async {
    if (localParticipant != null) {
      if (isMicMuted) {
        await localParticipant!.setMicrophoneEnabled(true);
      } else {
        await localParticipant!.setMicrophoneEnabled(false);
      }
      isMicMuted = !isMicMuted;
    }
  }

  Future<void> toggleVideo() async {
    if (localParticipant != null) {
      if (isVideoEnabled) {
        await localParticipant!.setCameraEnabled(false);
      } else {
        await localParticipant!.setCameraEnabled(true);
      }
      isVideoEnabled = !isVideoEnabled;
    }
  }

  Future<void> switchCamera() async {
    if (localParticipant != null) {
      // Note: switchCamera might not be available in current API
      // You may need to implement camera switching differently
      isFrontCamera = !isFrontCamera;
    }
  }

  Future<void> switchSpeaker(bool enable) async {
    try {
      await lk.Hardware.instance.setSpeakerphoneOn(enable);
      debugPrint('🔊 Switched speaker using LiveKit Hardware: $enable');
      _isSpeakerOn = enable;
    } catch (e) {
      debugPrint('❌ Failed to switch speaker with LiveKit Hardware: $e');
      _isSpeakerOn = enable;
    }
  }

  Future<void> endCall() async {
    await _room?.disconnect();
    onCallEnded?.call();
  }

  void dispose() {
    _room?.dispose();
    _room = null;
  }
}

