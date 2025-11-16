import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_off/screen_off.dart';

import '../../../../../core/utilities/services/call_foreground_service.dart';
import '../../../../../core/utilities/services/call_service.dart';
import '../../../../../core/utilities/services/firebase_notification.dart';
part 'teacher_call_state.dart';

class TeacherCallCubit extends Cubit<TeacherCallState> {
  final CallModel callModel;
  TeacherCallCubit({
    required this.callModel,
  }) : super(TeacherCallInitial());

  static TeacherCallCubit get(context) => BlocProvider.of(context);

  late AgoraCallService callService;
  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();

  Future<void> requestPermissions() async {
    // check and request microphone permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<bool> requestCameraPermission() async {
    var cameraStatus = await Permission.camera.status;

    if (cameraStatus.isDenied) {
      cameraStatus = await Permission.camera.request();
    }

    if (cameraStatus.isPermanentlyDenied) {
      emit(CameraPermissionPermanentlyDenied());
      return false;
    }

    if (cameraStatus.isGranted) {
      return true;
    } else {
      emit(CameraPermissionDenied());
      return false;
    }
  }

  Future<void> playAnswerSound() async {
    _player.setReleaseMode(ReleaseMode.stop);
    await _player.play(AssetSource('audio/userJoinedSound.mp3'));
  }

  Future<void> stopSound() async {
    await _player.stop();
  }

  void initCall() async {
    if (Platform.isAndroid) {
      await requestPermissions();
      // 🆕 Initialize في silent mode للمعلم
      await CallForegroundService.init(silentMode: true);
      await Future.delayed(Duration(milliseconds: 300));
    }
    await setupAgoraCallService();
    joinAgoraChannel(callModel.callId);
  }

  Future<void> endCall() async {
    try {
      if (Platform.isAndroid) {
        await CallForegroundService.stopCallService();
      }
      final batch = db.batch();
      final callRef = db.collection('calls').doc(callModel.callId);
      final userRef = db.collection('users').doc(callModel.teacherUid);
      batch.update(callRef, {
        'status': 'ended',
        'endedTime': FieldValue.serverTimestamp(),
      });

      batch.update(userRef, {
        'totalMinutes': FieldValue.increment(_elapsedTime.inMinutes),
        'totalSessions': FieldValue.increment(1),
        'isBusy': false,
      });
      await Future.wait([
        batch.commit(),
        endAgoraCall(),
        AppFirebaseNotification.endCall(callModel.callId),
      ]);
      emit(CallFinished());
    } catch (error) {
      emit(AgoraConnectionError(error: error.toString()));
    }
  }

  StreamSubscription<DocumentSnapshot>? _callSubscription;

  bool isCallConnected = false;
  bool isMicMuted = false;
  bool isSpeakerOn = true;
  bool isVideoEnabled = false;
  bool isRemoteVideoEnabled = false;
  int? remoteUid;

  Future<void> setupAgoraCallService() async {
    callService = AgoraCallService();
    callService.onUserJoined = (uid) {
      remoteUid = uid;
    };
    callService.onUserLeft = (uid) async {
      await endCall();
    };
    callService.onError = (error) {
      emit(AgoraConnectionError(error: error));
    };
    callService.onCallEnded = () {};
    callService.onConnectionSuccess = () {
      startCallTimer();
      isCallConnected = true;
      playAnswerSound();
      HapticFeedback.vibrate();
      if (Platform.isIOS) {
        callService.switchSpeaker(true);
      }
      emit(TeacherCallInitial());
    };
    callService.onRemoteVideoStateChanged = (uid, enabled) {
      isRemoteVideoEnabled = enabled;
      emit(RemoteVideoStateChanged());
    };
    await callService.initialize();
  }

  Future<void> joinAgoraChannel(String channelId) async {
    await callService.joinChannel(channelId);
  }

  Future<void> endAgoraCall() async {
    await callService.endCall();
  }

  Future<void> toggleMicMute() async {
    await callService.toggleMute();
    isMicMuted = callService.isMicMuted;
    HapticFeedback.heavyImpact();
    emit(TeacherCallInitial());
  }

  Future<void> toggleVideo() async {
    try {
      if (!isVideoEnabled && Platform.isAndroid) {
        bool hasPermission = await requestCameraPermission();
        if (!hasPermission) {
          // Permission denied, don't toggle video
          return;
        }
      }

      await callService.toggleVideo();
      isVideoEnabled = callService.isVideoEnabled;
      HapticFeedback.heavyImpact();

      // When video is enabled, automatically turn on speaker and disable proximity sensor
      if (isVideoEnabled) {
        if (!isSpeakerOn) {
          await switchSpeaker();
        }
        if (Platform.isAndroid) {
          disableProximitySensor();
        }
      }

      emit(VideoStateChanged());
    } catch (e) {
      emit(AgoraConnectionError(error: 'فشل تشغيل الفيديو: $e'));
    }
  }

  Future<void> switchCamera() async {
    await callService.switchCamera();
    HapticFeedback.heavyImpact();
    emit(TeacherCallInitial());
  }

  Future<void> switchSpeaker() async {
    await callService.switchSpeaker(!callService.isSpeakerOn);
    isSpeakerOn = callService.isSpeakerOn;
    HapticFeedback.heavyImpact();
    if (Platform.isAndroid) {
      if (!isSpeakerOn && !isVideoEnabled) {
        enableProximitySensor();
      } else {
        disableProximitySensor();
      }
    }
    emit(TeacherCallInitial());
  }

  final StreamController<String> _callTimerController =
  StreamController<String>.broadcast();

  Stream<String> get callTimerStream => _callTimerController.stream;

  Timer? _callDurationTimer;
  Duration _elapsedTime = Duration.zero;

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void startCallTimer() {
    if (_callDurationTimer != null && _callDurationTimer!.isActive) {
      return;
    }

    _elapsedTime = Duration.zero;
    _callTimerController.add(_formatDuration(_elapsedTime));

    // 🆕 Start في silent mode - بدون notification
    if (Platform.isAndroid) {
      CallForegroundService.startCallService(
        callerName: callModel.studentName,
        callDuration: _formatDuration(_elapsedTime),
        silentMode: true, // 👈 المهم ده
      );
    }

    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      final formattedTime = _formatDuration(_elapsedTime);
      _callTimerController.add(formattedTime);

      // 🆕 مش محتاجين update لأن مفيش notification أصلاً
    });
  }

  void stopCallTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
  }

  StreamSubscription<dynamic>? _proximitySubscription;
  bool _isNear = false;

  void enableProximitySensor() {
    _proximitySubscription = ProximitySensor.events.listen((event) async {
      _isNear = event > 0;
      if (_isNear) {
        await ScreenOff.turnScreenOff();
      } else {
        await ScreenOff.turnScreenOn();
      }
    });
  }

  void disableProximitySensor() {
    _proximitySubscription?.cancel();
    _proximitySubscription = null;
  }

  @override
  Future<void> close() {
    stopSound();
    _player.dispose();
    _callTimerController.close();
    stopCallTimer();
    _callSubscription?.cancel();
    callService.dispose();
    if (Platform.isAndroid) {
      disableProximitySensor();
      CallForegroundService.stopCallService();
    }
    return super.close();
  }
}