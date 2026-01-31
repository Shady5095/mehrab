import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import '../../config/app_config.dart';
import 'call_state_service.dart';

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

    // Handle track publication/unpublication events
    if (_room != null) {
      // Check for any track changes in remote participants
      for (final participant in _room!.remoteParticipants.values) {
        // A video track is considered "enabled" if:
        // 1. There's a video track publication
        // 2. The track is not null
        // 3. The publication is not muted
        final hasVideo = participant.trackPublications.values
            .any((pub) => pub.kind == lk.TrackType.VIDEO && pub.track != null && !pub.muted);

        // Only notify if state actually changed
        final lastKnownState = _lastVideoStates[participant.identity] ?? false;
        if (lastKnownState != hasVideo) {
          _lastVideoStates[participant.identity] = hasVideo;
          debugPrint('📹 Room event - Video state changed for ${participant.identity}: $hasVideo');
          onRemoteVideoStateChanged?.call(participant.identity, hasVideo);
        }
      }
    }
  }

  Future<void> connect(String token, String roomName, {String? callId}) async {
    try {
      // Add timeout for faster failure detection
      await _room?.connect(
        'wss://${AppConfig.livekitUrl.replaceFirst('https://', '')}',
        token,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Connection timeout - LiveKit server not responding');
      });

      // Set call state
      final effectiveCallId = callId ?? roomName;
      CallStateService().setInCall(effectiveCallId);

      // Set up participant event listeners
      _setupParticipantListeners();

      // Ensure microphone is enabled if not muted
      if (localParticipant != null && !isMicMuted) {
        await localParticipant!.setMicrophoneEnabled(true);
        debugPrint('🎤 Microphone enabled after connecting to room');
      }

    } catch (error) {
      onError?.call('Failed to connect to room: $error');
    }
  }

  // Track notified participants to avoid duplicate callbacks
  final Set<String> _notifiedParticipants = {};

  // Track last known video states to detect changes
  final Map<String, bool> _lastVideoStates = {};

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
          
          // Set up track listeners for this participant
          _setupTrackListeners(participant);
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

  // Track listeners for individual participants
  final Map<String, void Function()> _participantListeners = {};

  void _setupTrackListeners(lk.RemoteParticipant participant) {
    // Clean up existing listener for this participant
    final existingListener = _participantListeners[participant.identity];
    if (existingListener != null) {
      participant.removeListener(existingListener);
    }

    // Create a listener function for track events
    void trackEventListener() {
      // Check current video state by looking at track publications
      // A video track is considered "enabled" if:
      // 1. There's a video track publication
      // 2. The track is not null
      // 3. The publication is not muted
      final hasVideo = participant.trackPublications.values
          .any((pub) => pub.kind == lk.TrackType.VIDEO && pub.track != null && !pub.muted);

      // Only notify if state actually changed
      final lastKnownState = _lastVideoStates[participant.identity] ?? false;
      if (lastKnownState != hasVideo) {
        _lastVideoStates[participant.identity] = hasVideo;
        debugPrint('📹 Participant listener - Video state changed for ${participant.identity}: $hasVideo');
        onRemoteVideoStateChanged?.call(participant.identity, hasVideo);
      }
    }

    // Add the listener to the participant
    participant.addListener(trackEventListener);

    // Store the listener for cleanup
    _participantListeners[participant.identity] = trackEventListener;

    // Also check initial state when setting up listener
    final initialHasVideo = participant.trackPublications.values
        .any((pub) => pub.kind == lk.TrackType.VIDEO && pub.track != null && !pub.muted);
    _lastVideoStates[participant.identity] = initialHasVideo;
    debugPrint('📹 Initial video state for ${participant.identity}: video=$initialHasVideo');
    onRemoteVideoStateChanged?.call(participant.identity, initialHasVideo);
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
    CallStateService().setNotInCall();
    onCallEnded?.call();
  }

  void dispose() {
    // Clean up participant listeners
    if (_room != null) {
      for (final participant in _room!.remoteParticipants.values) {
        final listener = _participantListeners[participant.identity];
        if (listener != null) {
          participant.removeListener(listener);
        }
      }
    }
    _participantListeners.clear();
    _lastVideoStates.clear();

    _room?.dispose();
    _room = null;
  }
}

