import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/services/firebase_notification.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:mehrab/features/teacher_call/presentation/manager/student_call_cubit/student_call_state.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_off/screen_off.dart';

import '../../../../../core/utilities/services/call_service.dart';

class StudentCallCubit extends Cubit<StudentCallState> {
  StudentCallCubit({required this.teacherModel}) : super(TeacherCallInitial());

  final TeacherModel teacherModel;

  static StudentCallCubit get(context) => BlocProvider.of(context);

  late AgoraCallService callService;
  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();

  Future<void> requestPermissions() async {
    if(Platform.isIOS)return;
    var micStatus = await Permission.microphone.status;

    if (micStatus.isDenied) {
      micStatus = await Permission.microphone.request();
    }

    if (micStatus.isPermanentlyDenied) {
      emit(MicrophonePermanentlyDenied());
      return;
    }

    if (micStatus.isGranted) {
      emit(MicrophoneAllowed());
    } else {
      emit(MicrophoneNotAllowed());
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

  Future<void> playSound() async {
    _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/phone-ringing.mp3'));
  }

  Future<void> playAnswerSound() async {
    _player.setReleaseMode(ReleaseMode.stop);
    await _player.play(AssetSource('audio/userJoinedSound.mp3'));
  }

  Future<void> stopSound() async {
    await _player.stop();
  }

  void initCall() async {
    await playSound();
    await requestPermissions();
    if (state is MicrophoneAllowed || Platform.isIOS) {
      await sendCallToTeacher();
      await setupAgoraCallService();
      callPushNotification();
      callListener();
      startCallTimeout();
      emit(SendCallToTeacherSuccess());
    }
  }

  String? callDocId;

  Future<void> sendCallToTeacher() async {
    await db
        .collection('calls')
        .add({
          'teacherUid': teacherModel.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'studentUid': currentUserModel?.uid ?? '',
          "studentName": currentUserModel?.name ?? '',
          "teacherName": teacherModel.name,
          "studentPhoto": currentUserModel?.imageUrl,
          "teacherPhoto": teacherModel.imageUrl,
          'status': "ringing",
        })
        .then((value) {
          callDocId = value.id;
          value.update({'callId': value.id});
        })
        .catchError((error) {
          emit(SendCallToTeacherFailure(error: error.toString()));
        });
  }

  Future<bool> checkIfAnotherCallRinging() async {
    final querySnapshot =
        await db
            .collection('calls')
            .where('teacherUid', isEqualTo: teacherModel.uid)
            .where('status', whereIn: ['answered', 'ringing'])
            .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> endCallBeforeAnswer({bool isByUser = false}) async {
    if (callDocId != null) {
      await db
          .collection('calls')
          .doc(callDocId)
          .update({'status': 'missed'})
          .then((value) {
            if (isByUser) {
              emit(CallEndedByUserState());
            } else {
              emit(CallEndedByTimeOut());
            }
          })
          .catchError((error) {
            emit(SendCallToTeacherFailure(error: error.toString()));
          });
    }
  }

  Future<void> endCallAfterAnswer({bool isByUser = false}) async {
    if (callDocId != null) {
      await db
          .collection('calls')
          .doc(callDocId)
          .update({
            'status': 'ended',
            "endedTime": FieldValue.serverTimestamp(),
          })
          .then((value) async {
            await endAgoraCall();
            if (isByUser) {
              emit(CallFinished(model: teacherModel));
            } else {
              emit(MaxDurationReached());
            }
          })
          .catchError((error) {
            emit(SendCallToTeacherFailure(error: error.toString()));
          });
    }
  }

  StreamSubscription<DocumentSnapshot>? _callSubscription;

  void callListener() {
    _callSubscription?.cancel();
    _callSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(callDocId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            CallModel data = CallModel.fromJson(snapshot.data() ?? {});
            if (data.status == 'answered') {
              if (!isCallAnswered) {
                onTeacherAnswer(data);
              }
            } else if (data.status == 'declined') {
              stopSound();
              emit(TeacherInAnotherCall());
            }
          }
        });
  }

  Future<void> onTeacherAnswer(CallModel data) async {
    isCallAnswered = true;
    emit(CallAnsweredState());
    stopSound();
    await Future.delayed(Duration(milliseconds: 300));
    _callTimeoutTimer?.cancel();
    joinAgoraChannel(data.callId);
  }

  void closeListener() {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(callDocId)
        .snapshots()
        .listen((snapshot) {})
        .cancel();
  }

  Timer? _callTimeoutTimer;

  void startCallTimeout() {
    _callTimeoutTimer = Timer(const Duration(minutes: 2), () {
      endCallBeforeAnswer();
    });
  }

  Timer? maxCallDurationTimer;

  void startMaxCallDurationTimer(Duration duration) {
    maxCallDurationTimer = Timer(duration, () async {
      endCallAfterAnswer(isByUser: false);
    });
  }

  bool isCallAnswered = false;
  bool isAnotherUserJoined = false;
  bool isMicMuted = false;
  bool isSpeakerOn = true;
  bool isVideoEnabled = false;
  bool isRemoteVideoEnabled = false;
  int? remoteUid;

  // 🆕 Stream لجودة الشبكة
  final StreamController<CallQuality> _networkQualityController =
      StreamController<CallQuality>.broadcast();

  Stream<CallQuality> get networkQualityStream =>
      _networkQualityController.stream;

  CallQuality _currentNetworkQuality = CallQuality.excellent;

  CallQuality get currentNetworkQuality => _currentNetworkQuality;

  Future<void> setupAgoraCallService() async {
    callService = AgoraCallService();
    callService.onUserJoined = (uid) {
      isAnotherUserJoined = true;
      remoteUid = uid;
      startCallTimer();
      playAnswerSound();
      HapticFeedback.vibrate();
      emit(AnotherUserJoinedSuccessfully());
    };
    callService.onUserLeft = (uid) async {
      await endCallAfterAnswer(isByUser: false);
    };
    callService.onError = (error) {
      emit(AgoraConnectionError(error: error));
    };
    callService.onCallEnded = () {};
    callService.onConnectionSuccess = () {};
    callService.onRemoteVideoStateChanged = (uid, enabled) {
      isRemoteVideoEnabled = enabled;
      emit(RemoteVideoStateChanged());
    };
    callService.onNetworkQualityChanged = (quality) {
      _currentNetworkQuality = quality;
      _networkQualityController.add(quality);
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
          return;
        }
      }
      await callService.toggleVideo();
      isVideoEnabled = callService.isVideoEnabled;
      HapticFeedback.heavyImpact();

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

  void callPushNotification() {
    AppFirebaseNotification.pushNotification(
      title: "اتصال جديد 📞",
      body:
          "يريد الطالب ${currentUserModel?.name ?? ''} بدأ جلسة معك, برجاء فتح التطبيق الان",
      dataInNotification: {},
      topic: teacherModel.uid,
    );
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

    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      _callTimerController.add(_formatDuration(_elapsedTime));
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
    closeListener();
    _callTimeoutTimer?.cancel();
    maxCallDurationTimer?.cancel();
    _callTimerController.close();
    _networkQualityController.close();
    stopCallTimer();
    _callSubscription?.cancel();
    callService.dispose();
    if (Platform.isAndroid) {
      disableProximitySensor();
    }
    return super.close();
  }
}
