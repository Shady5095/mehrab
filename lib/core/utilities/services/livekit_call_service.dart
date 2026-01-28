import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

/// Call quality levels for network quality indicator
enum CallQuality {
  excellent,
  good,
  poor,
}

/// LiveKit-based call service that replaces WebRTCCallService
/// Provides the same callback interface for easy migration
class LiveKitCallService {
  Room? _room;
  LocalParticipant? _localParticipant;
  RemoteParticipant? _remoteParticipant;

  // Local tracks
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;

  // Remote tracks
  VideoTrack? _remoteVideoTrack;
  AudioTrack? _remoteAudioTrack;

  // State
  bool isMicMuted = false;
  bool isVideoEnabled = false;
  bool isFrontCamera = true;
  bool _isSpeakerOn = false;
  bool isInitialized = false;

  // Quality monitoring
  Timer? _qualityTimer;
  ConnectionQuality _lastQuality = ConnectionQuality.excellent;

  // Getters for UI
  VideoTrack? get localVideoTrack => _localVideoTrack;
  VideoTrack? get remoteVideoTrack => _remoteVideoTrack;
  bool get isSpeakerOn => _isSpeakerOn;
  Room? get room => _room;

  // Callbacks matching the original WebRTCCallService interface
  Function(String peerId)? onUserJoined;
  Function(String peerId)? onUserLeft;
  Function(String error)? onError;
  Function()? onCallEnded;
  Function()? onConnectionSuccess;
  Function(String peerId, bool enabled)? onRemoteVideoStateChanged;
  Function(CallQuality quality)? onNetworkQualityChanged;
  Function()? onConnectionRecovering;

  /// Initialize the service
  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      // Set default audio output to speaker for calls
      await Hardware.instance.setSpeakerphoneOn(false);
      isInitialized = true;
      debugPrint('LiveKitCallService: Initialized');
    } catch (e) {
      debugPrint('LiveKitCallService: Error initializing - $e');
      onError?.call('Failed to initialize LiveKit: $e');
      rethrow;
    }
  }

  /// Connect to a LiveKit room
  ///
  /// [serverUrl] - LiveKit WebSocket server URL (wss://...)
  /// [token] - LiveKit access token from backend
  /// [roomName] - Room name for logging purposes
  Future<void> connectToRoom({
    required String serverUrl,
    required String token,
    required String roomName,
  }) async {
    try {
      debugPrint('LiveKitCallService: Connecting to room $roomName');

      // Create room options
      final roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultAudioPublishOptions: const AudioPublishOptions(
          audioBitrate: AudioPreset.speech,
        ),
        defaultVideoPublishOptions: const VideoPublishOptions(
          videoEncoding: VideoEncoding(
            maxBitrate: 1500000,
            maxFramerate: 30,
          ),
        ),
        defaultCameraCaptureOptions: CameraCaptureOptions(
          cameraPosition: CameraPosition.front,
          params: VideoParametersPresets.h720_169,
        ),
      );

      // Create and connect to room
      _room = Room();

      // Set up event listeners before connecting
      _setupRoomListeners();

      await _room!.connect(
        serverUrl,
        token,
        roomOptions: roomOptions,
      );

      _localParticipant = _room!.localParticipant;

      // Enable microphone by default
      await _enableMicrophone();

      debugPrint('LiveKitCallService: Connected to room');
      onConnectionSuccess?.call();

      // Start quality monitoring
      _startQualityMonitoring();
    } catch (e) {
      debugPrint('LiveKitCallService: Error connecting - $e');
      onError?.call('Failed to connect to room: $e');
      rethrow;
    }
  }

  void _setupRoomListeners() {
    if (_room == null) return;

    _room!.addListener(_onRoomEvent);
  }

  void _onRoomEvent() {
    final room = _room;
    if (room == null) return;

    // Check connection state
    switch (room.connectionState) {
      case ConnectionState.connected:
        debugPrint('LiveKitCallService: Room connected');
        break;
      case ConnectionState.reconnecting:
        debugPrint('LiveKitCallService: Reconnecting...');
        onConnectionRecovering?.call();
        break;
      case ConnectionState.disconnected:
        debugPrint('LiveKitCallService: Disconnected');
        onCallEnded?.call();
        break;
      default:
        break;
    }

    // Handle remote participants
    for (final participant in room.remoteParticipants.values) {
      _handleRemoteParticipant(participant);
    }
  }

  void _handleRemoteParticipant(RemoteParticipant participant) {
    if (_remoteParticipant == null) {
      _remoteParticipant = participant;
      debugPrint('LiveKitCallService: Remote participant joined - ${participant.identity}');
      onUserJoined?.call(participant.identity);
    }

    // Set up participant listener
    participant.addListener(() => _onParticipantChanged(participant));

    // Check for existing tracks
    for (final trackPublication in participant.trackPublications.values) {
      if (trackPublication.subscribed && trackPublication.track != null) {
        _handleTrack(trackPublication.track!, participant);
      }
    }
  }

  void _onParticipantChanged(RemoteParticipant participant) {
    // Handle track subscriptions
    for (final trackPublication in participant.trackPublications.values) {
      if (trackPublication.subscribed && trackPublication.track != null) {
        _handleTrack(trackPublication.track!, participant);
      }
    }

    // Check if participant left (no more tracks)
    if (participant.trackPublications.isEmpty && _remoteParticipant == participant) {
      _remoteParticipant = null;
      _remoteVideoTrack = null;
      _remoteAudioTrack = null;
      debugPrint('LiveKitCallService: Remote participant left');
      onUserLeft?.call(participant.identity);
    }
  }

  void _handleTrack(Track track, RemoteParticipant participant) {
    if (track is VideoTrack) {
      _remoteVideoTrack = track;
      debugPrint('LiveKitCallService: Remote video track received');
      onRemoteVideoStateChanged?.call(participant.identity, true);
    } else if (track is AudioTrack) {
      _remoteAudioTrack = track;
      debugPrint('LiveKitCallService: Remote audio track received');
    }
  }

  Future<void> _enableMicrophone() async {
    if (_localParticipant == null) return;

    try {
      await _localParticipant!.setMicrophoneEnabled(true);
      _localAudioTrack = _localParticipant!.audioTrackPublications
          .firstOrNull
          ?.track as LocalAudioTrack?;
      isMicMuted = false;
      debugPrint('LiveKitCallService: Microphone enabled');
    } catch (e) {
      debugPrint('LiveKitCallService: Error enabling microphone - $e');
      onError?.call('Failed to enable microphone: $e');
    }
  }

  /// Toggle microphone mute
  Future<void> toggleMute() async {
    if (_localParticipant == null) return;

    try {
      isMicMuted = !isMicMuted;
      await _localParticipant!.setMicrophoneEnabled(!isMicMuted);
      debugPrint('LiveKitCallService: Microphone ${isMicMuted ? "muted" : "unmuted"}');
    } catch (e) {
      debugPrint('LiveKitCallService: Error toggling mute - $e');
      isMicMuted = !isMicMuted; // Revert on error
    }
  }

  /// Toggle video on/off
  Future<void> toggleVideo() async {
    if (_localParticipant == null) return;

    try {
      isVideoEnabled = !isVideoEnabled;
      await _localParticipant!.setCameraEnabled(isVideoEnabled);

      if (isVideoEnabled) {
        _localVideoTrack = _localParticipant!.videoTrackPublications
            .firstOrNull
            ?.track as LocalVideoTrack?;
      } else {
        _localVideoTrack = null;
      }

      debugPrint('LiveKitCallService: Video ${isVideoEnabled ? "enabled" : "disabled"}');
    } catch (e) {
      debugPrint('LiveKitCallService: Error toggling video - $e');
      isVideoEnabled = !isVideoEnabled; // Revert on error
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (!isVideoEnabled || _localVideoTrack == null) return;

    try {
      isFrontCamera = !isFrontCamera;
      final position = isFrontCamera ? CameraPosition.front : CameraPosition.back;
      await _localVideoTrack!.setCameraPosition(position);
      debugPrint('LiveKitCallService: Camera switched to ${isFrontCamera ? "front" : "back"}');
    } catch (e) {
      debugPrint('LiveKitCallService: Error switching camera - $e');
      isFrontCamera = !isFrontCamera; // Revert on error
    }
  }

  /// Switch between speaker and earpiece
  Future<void> switchSpeaker(bool useSpeaker) async {
    try {
      _isSpeakerOn = useSpeaker;
      await Hardware.instance.setSpeakerphoneOn(useSpeaker);
      debugPrint('LiveKitCallService: Speaker ${useSpeaker ? "enabled" : "disabled"}');
    } catch (e) {
      debugPrint('LiveKitCallService: Error switching speaker - $e');
      _isSpeakerOn = !useSpeaker; // Revert on error
    }
  }

  void _startQualityMonitoring() {
    _qualityTimer?.cancel();
    _qualityTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkConnectionQuality();
    });
  }

  void _checkConnectionQuality() {
    if (_room == null || _localParticipant == null) return;

    final quality = _localParticipant!.connectionQuality;
    final callQuality = _mapConnectionQuality(quality);

    if (quality != _lastQuality) {
      _lastQuality = quality;
      onNetworkQualityChanged?.call(callQuality);
    }
  }

  CallQuality _mapConnectionQuality(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return CallQuality.excellent;
      case ConnectionQuality.good:
        return CallQuality.good;
      case ConnectionQuality.poor:
      case ConnectionQuality.lost:
        return CallQuality.poor;
      default:
        return CallQuality.good;
    }
  }

  /// End the call and disconnect from room
  Future<void> endCall() async {
    try {
      _qualityTimer?.cancel();
      _qualityTimer = null;

      if (isVideoEnabled) {
        await _localParticipant?.setCameraEnabled(false);
        isVideoEnabled = false;
      }

      await _room?.disconnect();
      onCallEnded?.call();
      debugPrint('LiveKitCallService: Call ended');
    } catch (e) {
      debugPrint('LiveKitCallService: Error ending call - $e');
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    try {
      _qualityTimer?.cancel();
      _qualityTimer = null;

      await _room?.disconnect();
      _room?.removeListener(_onRoomEvent);
      _room?.dispose();
      _room = null;

      _localParticipant = null;
      _remoteParticipant = null;
      _localVideoTrack = null;
      _localAudioTrack = null;
      _remoteVideoTrack = null;
      _remoteAudioTrack = null;

      isInitialized = false;
      debugPrint('LiveKitCallService: Disposed');
    } catch (e) {
      debugPrint('LiveKitCallService: Error disposing - $e');
    }
  }
}
