import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/services/sensitive_app_constants.dart';

// Enum لمستويات جودة الاتصال
enum CallQuality {
  excellent, // 3 شرط
  good,      // شرطين
  poor,      // شرطه واحدة
}

class AgoraCallService {
  RtcEngine? _engine;
  bool isMicMuted = false;
  bool isInitialized = false;
  bool _isSpeakerOn = true;
  bool isVideoEnabled = false;
  bool isFrontCamera = true;

  // Callbacks
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserLeft;
  Function(String error)? onError;
  Function()? onCallEnded;
  Function()? onConnectionSuccess;
  Function(int uid, bool enabled)? onRemoteVideoStateChanged;
  Function(CallQuality quality)? onNetworkQualityChanged; // 🆕 Callback للجودة

  // Initialize Agora Engine
  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(
        RtcEngineContext(
          appId: SensitiveAppConstants.getCurrentAppId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      debugPrint('✅ Agora Engine created and initialized');

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
          onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid,
              RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
            debugPrint('📹 Remote video state changed: uid=$remoteUid, state=$state');
            if (state == RemoteVideoState.remoteVideoStateDecoding ||
                state == RemoteVideoState.remoteVideoStateStarting) {
              onRemoteVideoStateChanged?.call(remoteUid, true);
            } else if (state == RemoteVideoState.remoteVideoStateStopped) {
              onRemoteVideoStateChanged?.call(remoteUid, false);
            }
          },
          // 🆕 مراقبة جودة الشبكة
          onNetworkQuality: (RtcConnection connection, int remoteUid,
              QualityType txQuality, QualityType rxQuality) {
            final worstQuality = txQuality.index > rxQuality.index ? txQuality : rxQuality;
            CallQuality quality;
            switch (worstQuality) {
              case QualityType.qualityExcellent:
              case QualityType.qualityGood:
                quality = CallQuality.excellent; // 3 شرط
                break;
              case QualityType.qualityPoor:
              case QualityType.qualityBad:
                quality = CallQuality.good; // شرطين
                break;
              case QualityType.qualityVbad:
              case QualityType.qualityDown:
              default:
                quality = CallQuality.poor; // شرطه
                break;
            }
            onNetworkQualityChanged?.call(quality);
          },
        ),
      );

      await _engine!.enableAudio();
      debugPrint('✅ Audio enabled');

      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioChatroom,
      );
      debugPrint('✅ Audio profile set');

      await _engine!.setDefaultAudioRouteToSpeakerphone(true);
      debugPrint('✅ Default audio route set to speakerphone');

      await _engine!.enableVideo();
      debugPrint('✅ Video enabled');

      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1280, height: 720),
          frameRate: 25,
          bitrate: 0,
        ),
      );
      debugPrint('✅ Video encoder configured');

      isInitialized = true;
      debugPrint('✅ Agora Engine fully initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Agora: $e');
      onError?.call('فشل في تهيئة المكالمة: $e');
      isInitialized = false;
      rethrow;
    }
  }

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
          autoSubscribeVideo: true,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
        ),
      );

      debugPrint('✅ Join channel request sent successfully');
    } catch (e) {
      debugPrint('❌ Error joining channel: $e');
      onError?.call('فشل الانضمام للمكالمة: $e');
      rethrow;
    }
  }

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

  Future<void> toggleMute() async {
    if (_engine != null && isInitialized) {
      try {
        isMicMuted = !isMicMuted;
        await _engine!.muteLocalAudioStream(isMicMuted);
        debugPrint('🎤 Audio ${isMicMuted ? 'muted' : 'enabled'}');
      } catch (e) {
        debugPrint('❌ Error toggling audio: $e');
        isMicMuted = !isMicMuted;
      }
    }
  }

  Future<void> toggleVideo() async {
    if (_engine != null && isInitialized) {
      try {
        isVideoEnabled = !isVideoEnabled;

        if (isVideoEnabled) {
          await _engine!.startPreview();
          await _engine!.enableLocalVideo(true);
          await _engine!.muteLocalVideoStream(false);
        } else {
          await _engine!.muteLocalVideoStream(true);
          await _engine!.enableLocalVideo(false);
          await _engine!.stopPreview();
        }

        await _engine!.updateChannelMediaOptions(
          ChannelMediaOptions(
            publishCameraTrack: isVideoEnabled,
          ),
        );

        debugPrint('📹 Video ${isVideoEnabled ? 'enabled' : 'disabled'}');
      } catch (e) {
        debugPrint('❌ Error toggling video: $e');
        isVideoEnabled = !isVideoEnabled;
        rethrow;
      }
    }
  }

  Future<void> switchCamera() async {
    if (_engine != null && isInitialized && isVideoEnabled) {
      try {
        await _engine!.switchCamera();
        isFrontCamera = !isFrontCamera;
        debugPrint('📹 Camera switched to ${isFrontCamera ? 'front' : 'back'}');
      } catch (e) {
        debugPrint('❌ Error switching camera: $e');
      }
    }
  }

  Future<void> switchSpeaker(bool useSpeaker) async {
    if (_engine != null && isInitialized) {
      try {
        _isSpeakerOn = useSpeaker;
        await _engine!.setEnableSpeakerphone(useSpeaker);
        debugPrint('🔊 Speaker ${useSpeaker ? 'enabled' : 'disabled'}');
      } catch (e) {
        debugPrint('❌ Error switching speaker: $e');
        _isSpeakerOn = !useSpeaker;
      }
    }
  }

  bool get isSpeakerOn => _isSpeakerOn;
  RtcEngine? get engine => _engine;

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

  Future<void> endCall() async {
    try {
      if (isVideoEnabled) {
        await toggleVideo();
      }
      await leaveChannel();
      onCallEnded?.call();
      debugPrint('✅ Call ended successfully');
    } catch (e) {
      debugPrint('❌ Error ending call: $e');
    }
  }

  Future<void> dispose() async {
    try {
      if (isVideoEnabled) {
        await _engine!.stopPreview();
      }
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