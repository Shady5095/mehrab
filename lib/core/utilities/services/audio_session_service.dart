import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

class AudioSessionService {
  AudioSession? _session;
  bool _isConfigured = false;

  Future<void> configureForCall() async {
    if (_isConfigured) return;

    try {
      _session = await AudioSession.instance;

      await _session!.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.defaultToSpeaker |
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.allowBluetoothA2dp,
        // voiceChat mode enables hardware echo cancellation on iOS
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientExclusive,
        androidWillPauseWhenDucked: false,
      ));

      // Activate the audio session
      await _session!.setActive(true);

      _isConfigured = true;
      debugPrint('AudioSession: Configured and activated for call');
    } catch (e) {
      debugPrint('AudioSession Error: $e');
    }
  }

  Future<void> setActive(bool active) async {
    if (_session == null) {
      await configureForCall();
    }

    try {
      await _session!.setActive(active);
      debugPrint('AudioSession: Active = $active');
    } catch (e) {
      debugPrint('AudioSession Error setting active: $e');
    }
  }

  Future<void> switchToSpeaker() async {
    if (Platform.isIOS) {
      try {
        await _session?.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker |
              AVAudioSessionCategoryOptions.allowBluetooth,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
        ));
        debugPrint('AudioSession: Switched to speaker');
      } catch (e) {
        debugPrint('AudioSession Error switching to speaker: $e');
      }
    }
  }

  Future<void> switchToEarpiece() async {
    if (Platform.isIOS) {
      try {
        await _session?.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
        ));
        debugPrint('AudioSession: Switched to earpiece');
      } catch (e) {
        debugPrint('AudioSession Error switching to earpiece: $e');
      }
    }
  }

  void dispose() {
    _session = null;
    _isConfigured = false;
    debugPrint('AudioSession: Disposed');
  }
}
