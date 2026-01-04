import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
import 'package:uuid/uuid.dart';
import '../../../../../core/utilities/services/call_foreground_service.dart';
import '../../../../../core/utilities/services/call_kit_service.dart';
import '../../../../../core/utilities/services/call_service.dart';

class StudentCallCubit extends Cubit<StudentCallState> {
  StudentCallCubit({required this.teacherModel}) : super(TeacherCallInitial());

  final TeacherModel teacherModel;

  static StudentCallCubit get(context) => BlocProvider.of(context);

  late AgoraCallService callService;
  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();
  static const _uuid = Uuid();

  Future<void> requestPermissions() async {
    var micStatus = await Permission.microphone.status;

    if (micStatus.isDenied) {
      micStatus = await Permission.microphone.request();
    }

    if (micStatus.isPermanentlyDenied) {
      if (Platform.isIOS) {
        emit(MicrophoneAllowed());
      } else {
        emit(MicrophonePermanentlyDenied());
      }
      return;
    }

    if (micStatus.isGranted) {
      emit(MicrophoneAllowed());
    } else {
      if (Platform.isIOS) {
        emit(MicrophoneAllowed());
      } else {
        emit(MicrophoneNotAllowed());
      }
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

  Future<void> playMessageReceivedSound() async {
    _player.setReleaseMode(ReleaseMode.stop);
    await _player.play(AssetSource('audio/messageReceivedSound.mp3'));
  }

  Future<void> stopSound() async {
    await _player.stop();
  }

  void initCall() async {
    await playSound();
    await requestPermissions();
    if (state is MicrophoneAllowed) {
      if (Platform.isAndroid) {
        await CallForegroundService.init(silentMode: false);
      }
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
    try {
      final batch = db.batch();
      callDocId = _uuid.v4();
      final callRef = db.collection('calls').doc(callDocId);
      batch.set(callRef, {
        'callId': callDocId,
        'teacherUid': teacherModel.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'studentUid': currentUserModel?.uid ?? '',
        'studentName': currentUserModel?.name ?? '',
        'teacherName': teacherModel.name,
        'studentPhoto': currentUserModel?.imageUrl,
        'teacherPhoto': teacherModel.imageUrl,
        'status': 'ringing',
      });
      final teacherRef = db.collection('users').doc(teacherModel.uid);
      batch.update(teacherRef, {'isBusy': true});
      await batch.commit();

    } catch (error) {
      emit(SendCallToTeacherFailure(error: error.toString()));
    }
  }

  Future<void> endCallBeforeAnswer({bool isByUser = false}) async {
    if (callDocId == null) return;
    try {
      _clearPreComment();
      final batch = db.batch();
      final callRef = db.collection('calls').doc(callDocId);
      final teacherRef = db.collection('users').doc(teacherModel.uid);
      batch.update(callRef, {'status': 'missed'});
      batch.update(teacherRef, {'isBusy': false});
      await batch.commit();
      if (isByUser) {
        emit(CallEndedByUserState());
      } else {
        emit(CallEndedByTimeOut());
      }

    } catch (error) {
      emit(SendCallToTeacherFailure(error: error.toString()));
    }
  }


  Future<void> endCallAfterAnswer({bool isByUser = false}) async {
    if (callDocId == null) return;
    try {
      _clearPreComment();
      if (Platform.isAndroid) {
        await CallForegroundService.stopCallService();
      }
      final updateCall = db.collection('calls').doc(callDocId).update({
        'status': 'ended',
        'endedTime': FieldValue.serverTimestamp(),
      });
      final endCallAgora = endAgoraCall();
      await Future.wait([updateCall, endCallAgora]);
      if (isByUser) {
        emit(CallFinished(model: teacherModel));
      } else {
        emit(MaxDurationReached());
      }
    } catch (error) {
      emit(AgoraConnectionError(error: error.toString()));
    }
  }

  StreamSubscription<DocumentSnapshot>? _callSubscription;
  String? currentPreComment;
  Timer? _preCommentTimer;

  void _clearPreComment() {
    _preCommentTimer?.cancel();
    _preCommentTimer = null;
    currentPreComment = null;
    emit(PreCommentCleared());
  }

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
              onCallDecline();
              emit(TeacherInAnotherCall());
            }
            
            // Listen for pre-comments (only if call is answered and not ended)
            if (isCallAnswered && 
                data.status != 'ended' && 
                data.status != 'missed') {
              final preComment = snapshot.data()?['preComment'] as String?;
              
              if (preComment != null && preComment != currentPreComment) {
                currentPreComment = preComment;
                HapticFeedback.vibrate();
                
                // Play sound for every new message
                playMessageReceivedSound();
                
                emit(PreCommentReceived(comment: preComment));
                
                // Clear comment after 7 seconds
                _preCommentTimer?.cancel();
                _preCommentTimer = Timer(const Duration(seconds: 7), () {
                  if (currentPreComment == preComment) {
                    currentPreComment = null;
                    emit(PreCommentCleared());
                  }
                });
              }
            } else if (data.status == 'ended' || data.status == 'missed') {
              // Clear comment if call ended
              _clearPreComment();
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
    // Keep listening for pre-comments, don't cancel subscription
    joinAgoraChannel(data.callId);
  }

  Future<void> onCallDecline() async {
    stopSound();
    _clearPreComment();
    await db.collection('users').doc(teacherModel.uid).update({'isBusy': false});
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

  Future<void> setupAgoraCallService() async {
    callService = AgoraCallService();
    callService.onUserJoined = (uid) {
      isAnotherUserJoined = true;
      remoteUid = uid;
      startCallTimer();
      playAnswerSound();
      HapticFeedback.vibrate();
      if (Platform.isIOS) {
        callService.switchSpeaker(true);
      }
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
      // If video is currently off and user wants to turn it on, request permission first
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

  void callPushNotification() {
    if (callDocId == null || callDocId!.isEmpty) {
      debugPrint(
        '❌ ERROR: callDocId is null or empty, cannot send notification',
      );
      return;
    }

    final studentPhoto = ImageHelper.getValidImageUrl(
      currentUserModel?.imageUrl,
    );

    debugPrint('📱 Sending call notification with UUID: $callDocId');

    AppFirebaseNotification.pushIncomingCallNotification(
      callId: callDocId!,
      callerName: currentUserModel?.name ?? 'طالب',
      callerPhoto: studentPhoto,
      teacherUid: teacherModel.uid,
      studentUid: currentUserModel?.uid ?? '',
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

    // 🆕 Start مع notification للطالب
    if (Platform.isAndroid) {
      CallForegroundService.startCallService(
        callerName: teacherModel.name,
        callDuration: _formatDuration(_elapsedTime),
        silentMode: false, // 👈 يظهر notification
      );
    }

    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      final formattedTime = _formatDuration(_elapsedTime);
      _callTimerController.add(formattedTime);


      if (_elapsedTime.inSeconds % 1 == 0 && Platform.isAndroid) {
        CallForegroundService.updateCallService(
          callerName: teacherModel.name,
          callDuration: formattedTime,
        );
      }
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
    _clearPreComment();
    _callTimerController.close();
    stopCallTimer();
    _callSubscription?.cancel();
    callService.dispose();
    if (Platform.isAndroid) {
      disableProximitySensor();
      CallForegroundService.stopCallService();
    }
    // End any active CallKit calls
    if (callDocId != null) {
      AppFirebaseNotification.endCall(callDocId!);
    }
    return super.close();
  }
}
