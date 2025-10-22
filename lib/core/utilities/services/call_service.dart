import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/services/sensitive_app_constants.dart';

class AgoraCallService {
  RtcEngine? _engine;
  bool isMicMuted = false;
  bool isInitialized = false;
  bool _isSpeakerOn = false;

  // Callbacks
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserLeft;
  Function(String error)? onError;
  Function()? onCallEnded;
  Function()? onConnectionSuccess;

  // Initialize Agora Engine
  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      // Create RTC engine
      _engine = createAgoraRtcEngine();

      // Initialize first before any other operations
      await _engine!.initialize(
        RtcEngineContext(
          appId: SensitiveAppConstants.agoraAppId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      debugPrint('✅ Agora Engine created and initialized');

      // Register event handlers AFTER initialization
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('✅ Agora: Successfully joined channel ${connection.channelId}');
            onConnectionSuccess?.call();
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            debugPrint('✅ Agora: User $uid joined');
            onUserJoined?.call(uid);
          },
          onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
            debugPrint('❌ Agora: User $uid left (reason: $reason)');
            onUserLeft?.call(uid);
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('❌ Agora Error: $err - $msg');
            onError?.call('خطأ في الاتصال: $msg');
          },
          onConnectionLost: (RtcConnection connection) {
            debugPrint('❌ Agora: Connection lost');
            onError?.call('تم قطع الاتصال');
          },
          onConnectionStateChanged: (RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason) {
            debugPrint('🔄 Agora: Connection state changed to $state (reason: $reason)');

            if (state == ConnectionStateType.connectionStateConnected) {
              onConnectionSuccess?.call();
            }
          },
          onAudioRoutingChanged: (int num) {
            debugPrint('🔊 Audio route changed to: $num');
          },
        ),
      );

      /*// Enable audio AFTER initialization
      await _engine!.enableAudio();
      debugPrint('✅ Audio enabled');

      // Set audio profile for voice call
      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioChatroom,
      );
      debugPrint('✅ Audio profile set');

      // Configure audio settings
      await _engine!.setDefaultAudioRouteToSpeakerphone(true);
      debugPrint('✅ Default audio route set to speakerphone');*/

      isInitialized = true;
      debugPrint('✅ Agora Engine fully initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Agora: $e');
      onError?.call('فشل في تهيئة المكالمة: $e');
      isInitialized = false;
      rethrow;
    }
  }

  // Request necessary permissions


  // Join channel
  Future<void> joinChannel(String channelId, {int uid = 0}) async {
    if (!isInitialized) {
      debugPrint('⚠️ Engine not initialized, initializing now...');
      await initialize();
    }

    if (_engine == null) {
      throw Exception('Agora engine is null');
    }

    try {
      debugPrint('📞 Attempting to join channel: $channelId with uid: $uid');

      await _engine!.joinChannel(
        token: '',
        channelId: channelId,
        uid: uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          publishMicrophoneTrack: true,
        ),
      );

      debugPrint('✅ Join channel request sent successfully');
    } catch (e) {
      debugPrint('❌ Error joining channel: $e');
      onError?.call('فشل الانضمام للمكالمة: $e');
      rethrow;
    }
  }

  // Leave channel
  Future<void> leaveChannel() async {
    if (_engine != null && isInitialized) {
      try {
        await _engine!.leaveChannel();
        debugPrint('✅ Left Agora channel');
      } catch (e) {
        debugPrint('❌ Error leaving channel: $e');
      }
    }
  }

  // Toggle microphone
  Future<void> toggleMute() async {
    if (_engine != null && isInitialized) {
      try {
        isMicMuted = !isMicMuted;
        await _engine!.muteLocalAudioStream(isMicMuted);
        debugPrint('🎤 Audio ${isMicMuted ? 'muted' : 'enabled'}');
      } catch (e) {
        debugPrint('❌ Error toggling audio: $e');
        // Revert state on error
        isMicMuted = !isMicMuted;
      }
    }
  }

  // Switch speaker
  Future<void> switchSpeaker(bool useSpeaker) async {
    if (_engine != null && isInitialized) {
      try {
        _isSpeakerOn = useSpeaker;
        await _engine!.setEnableSpeakerphone(useSpeaker);
        debugPrint('🔊 Speaker ${useSpeaker ? 'enabled' : 'disabled'}');
      } catch (e) {
        debugPrint('❌ Error switching speaker: $e');
        // Revert state on error
        _isSpeakerOn = !useSpeaker;
      }
    }
  }

  // Get current speaker state
  bool get isSpeakerOn => _isSpeakerOn;

  // Adjust recording volume (0-400, default 100)
  Future<void> adjustRecordingSignalVolume(int volume) async {
    if (_engine != null && isInitialized) {
      try {
        await _engine!.adjustRecordingSignalVolume(volume);
        debugPrint('🎚️ Recording volume adjusted to $volume');
      } catch (e) {
        debugPrint('❌ Error adjusting volume: $e');
      }
    }
  }

  // Adjust playback volume (0-400, default 100)
  Future<void> adjustPlaybackSignalVolume(int volume) async {
    if (_engine != null && isInitialized) {
      try {
        await _engine!.adjustPlaybackSignalVolume(volume);
        debugPrint('🎚️ Playback volume adjusted to $volume');
      } catch (e) {
        debugPrint('❌ Error adjusting volume: $e');
      }
    }
  }

  // End call and cleanup
  Future<void> endCall() async {
    try {
      await leaveChannel();
      onCallEnded?.call();
      debugPrint('✅ Call ended successfully');
    } catch (e) {
      debugPrint('❌ Error ending call: $e');
    }
  }

  // Dispose and release resources
  Future<void> dispose() async {
    try {
      await leaveChannel();

      if (_engine != null) {
        await _engine!.release();
        _engine = null;
      }

      isInitialized = false;
      debugPrint('✅ Agora Engine disposed and resources released');
    } catch (e) {
      debugPrint('❌ Error disposing Agora: $e');
    }
  }
}
