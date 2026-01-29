import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:mehrab/features/teacher_call/presentation/manager/student_call_cubit/student_call_state.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_off/screen_off.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/utilities/services/call_foreground_service.dart';
import '../../../../../core/utilities/services/call_kit_service.dart';
import '../../../../../core/utilities/services/livekit_call_service.dart';
import '../../../../../core/utilities/services/audio_session_service.dart';
import '../../../../../core/utilities/services/firebase_notification.dart';

class StudentCallCubit extends Cubit<StudentCallState> {
  StudentCallCubit({required this.teacherModel}) : super(TeacherCallInitial());

  final TeacherModel teacherModel;

  static StudentCallCubit get(BuildContext context) => BlocProvider.of(context);

  late LiveKitCallService callService;
  late AudioSessionService audioSessionService;

  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();
  static const _uuid = Uuid();

  String? remoteUid;

  // Connection timeout handling
  Timer? _connectionEstablishmentTimer;


  Future<void> requestPermissions() async {
    debugPrint('🎤 Requesting microphone permission');
    var micStatus = await Permission.microphone.status;
    debugPrint('🎤 Current microphone permission status: $micStatus');

    if (micStatus.isDenied) {
      debugPrint('🎤 Requesting microphone permission from user');
      micStatus = await Permission.microphone.request();
      debugPrint('🎤 Permission request result: $micStatus');
    }

    if (micStatus.isPermanentlyDenied) {
      if (Platform.isIOS) {
        emit(MicrophoneAllowed());
      } else {
        debugPrint('🎤 Microphone permission permanently denied');
        emit(MicrophonePermanentlyDenied());
      }
      return;
    }

    if (micStatus.isGranted) {
      debugPrint('🎤 Microphone permission granted');
      emit(MicrophoneAllowed());
    } else {
      if (Platform.isIOS) {
        emit(MicrophoneAllowed());
      } else {
        debugPrint('🎤 Microphone permission denied');
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
    debugPrint('📞 [STUDENT_CALL] initCall() started');

    await playSound();
    debugPrint('📞 [STUDENT_CALL] Playing call sound');

    await requestPermissions();
    debugPrint('📞 [STUDENT_CALL] Permissions requested, current state: $state');

    if (state is MicrophoneAllowed) {
      debugPrint('✅ [STUDENT_CALL] Microphone permission granted, proceeding with call setup');

      if (Platform.isAndroid) {
        debugPrint('🤖 [STUDENT_CALL] Android platform detected, initializing foreground service');
        await CallForegroundService.init(silentMode: false);
      }

      debugPrint('📞 [STUDENT_CALL] Sending call to teacher...');
      await sendCallToTeacher();

      debugPrint('📞 [STUDENT_CALL] Setting up LiveKit call service...');
      await setupLiveKitCallService();

      // Removed connectToLiveKitRoom from here - will connect after teacher answers
      debugPrint('📱 [STUDENT_CALL] Sending push notification...');
      callPushNotification();

      debugPrint('👂 [STUDENT_CALL] Setting up call listener...');
      callListener();

      debugPrint('⏰ [STUDENT_CALL] Starting call timeout...');
      startCallTimeout();

      debugPrint('✅ [STUDENT_CALL] Call initialization completed successfully');
      emit(SendCallToTeacherSuccess());
    } else {
      debugPrint('❌ [STUDENT_CALL] Microphone permission not granted, call initialization failed');
    }
  }

  String? callDocId;


  Future<void> sendCallToTeacher() async {
    isCallEnded = false; // Reset for new call
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
    if (callDocId == null || isCallEnded) return;
    isCallEnded = true;
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
      // If document not found, ignore as call might be already handled
      if (!error.toString().contains('not-found') && !error.toString().contains('document not found')) {
        emit(SendCallToTeacherFailure(error: error.toString()));
      } else {
        if (isByUser) {
          emit(CallEndedByUserState());
        } else {
          emit(CallEndedByTimeOut());
        }
      }
    }
  }


  Future<void> endCallAfterAnswer({bool isByUser = false}) async {
    if (callDocId == null || isCallEnded) return;
    isCallEnded = true;
    try {
      _clearPreComment();
      if (Platform.isAndroid) {
        await CallForegroundService.stopCallService();
      }
      final updateCall = db.collection('calls').doc(callDocId).update({
        'status': 'ended',
        'endedTime': FieldValue.serverTimestamp(),
      });
      final endCallLiveKit = endLiveKitCall();
      await Future.wait([updateCall, endCallLiveKit]);
      if (isByUser) {
        emit(CallFinished(model: teacherModel));
      } else {
        emit(MaxDurationReached());
      }
    } catch (error) {
      // If the call was already ended by the other user or document not found, don't emit error
      if (error.toString().contains('not-found') || error.toString().contains('document not found')) {
        if (!isByUser) {
          emit(AnotherUserLeft());
        } else {
          emit(CallFinished(model: teacherModel));
        }
      } else {
        if (!isByUser) {
          emit(AnotherUserLeft());
        } else {
          emit(AgoraConnectionError(error: error.toString()));
        }
      }
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
    debugPrint('📞 Teacher answered the call, connecting to LiveKit room');
    isCallAnswered = true;
    emit(CallAnsweredState());
    stopSound();
    await Future.delayed(Duration(milliseconds: 300));
    _callTimeoutTimer?.cancel();
    // Connect to LiveKit room after teacher answers
    await connectToLiveKitRoom();
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
  bool isCallEnded = false;
  bool isRemoteVideoEnabled = false;

  Future<void> setupLiveKitCallService() async {
    debugPrint('🔧 Setting up LiveKit call service');
    callService = LiveKitCallService();
    audioSessionService = AudioSessionService();

    debugPrint('🔊 Configuring audio session for call');
    // Configure audio session
    await audioSessionService.configureForCall();
    debugPrint('🔊 Audio session configured');

    callService.onUserJoined = (participantId) {
      debugPrint('👥 User joined LiveKit room: $participantId');
      // Cancel connection timeout since we're connected
      _connectionEstablishmentTimer?.cancel();
      isAnotherUserJoined = true;
      remoteUid = participantId;
      startCallTimer();
      playAnswerSound();
      HapticFeedback.vibrate();
      if (Platform.isIOS) {
        callService.switchSpeaker(true);
      }
      // Ensure audio session is active
      audioSessionService.setActive(true);
      emit(AnotherUserJoinedSuccessfully());
    };

    callService.onUserLeft = (participantId) async {
      debugPrint('👋 User left LiveKit room: $participantId');
      if (!isCallEnded) {
        await endCallAfterAnswer(isByUser: false);
      } else {
        emit(AnotherUserLeft());
      }
    };

    callService.onError = (error) {
      debugPrint('❌ LiveKit error: $error');
      emit(AgoraConnectionError(error: error));
    };

    callService.onCallEnded = () {
      debugPrint('📞 LiveKit call ended');
    };

    callService.onConnectionSuccess = () {
      debugPrint('🔗 LiveKit connection successful');
      // Cancel connection timeout on successful connection
      _connectionEstablishmentTimer?.cancel();
    };

    callService.onRemoteVideoStateChanged = (participantId, enabled) {
      debugPrint('📹 Remote video state changed for $participantId: $enabled');
      isRemoteVideoEnabled = enabled;
      emit(RemoteVideoStateChanged());
    };

    await callService.initialize();
    debugPrint('✅ LiveKit call service initialized');
  }

  Future<void> connectToLiveKitRoom() async {
    debugPrint('🔄 Attempting to connect to LiveKit room: $callDocId');
    try {
      // Get LiveKit token from server
      final token = await _getLiveKitToken();
      if (token == null) {
        debugPrint('❌ Failed to get LiveKit token - token is null');
        emit(AgoraConnectionError(error: 'Failed to get LiveKit token'));
        return;
      }

      debugPrint('✅ Got LiveKit token, connecting to room...');
      // Connect to LiveKit room
      await callService.connect(token, callDocId ?? '');
      debugPrint('✅ LiveKit connect method called successfully');
    } catch (error) {
      debugPrint('❌ Failed to connect to LiveKit room: $error');
      emit(AgoraConnectionError(error: 'Failed to connect to LiveKit room: $error'));
    }
  }

  Future<String?> _getLiveKitToken() async {
    try {
      // Get Firebase auth token
      final authToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);

      // Call the server's /token endpoint
      final response = await Dio().post(
        '${AppConfig.signalingServerUrl}/api/livekit/token',
        data: {
          'roomName': callDocId,
          'participantName': currentUserModel?.name ?? 'Student',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        return response.data['token'];
      }
    } catch (error) {
      if (error is DioException) {
        debugPrint('Failed to get LiveKit token: ${error.message}');
        if (error.response != null) {
          debugPrint('Status: ${error.response?.statusCode}');
          debugPrint('Data: ${error.response?.data}');
        }
      } else {
        debugPrint('Failed to get LiveKit token: $error');
      }
    }
    return null;
  }

  Future<void> endLiveKitCall() async {
    await callService.endCall();
  }

  Future<void> toggleMicMute() async {
    debugPrint('🎤 Toggling mic mute. Current state: $isMicMuted');
    await callService.toggleMute();
    isMicMuted = callService.isMicMuted;
    debugPrint('🎤 Mic mute toggled. New state: $isMicMuted');
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
    debugPrint('🔊 Switching speaker. Current state: $isSpeakerOn');
    await callService.switchSpeaker(!callService.isSpeakerOn);
    isSpeakerOn = callService.isSpeakerOn;
    debugPrint('🔊 Speaker switched. New state: $isSpeakerOn');
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
    debugPrint('📞 [STUDENT_CALL] callPushNotification() called');

    if (callDocId == null || callDocId!.isEmpty) {
      debugPrint('❌ [STUDENT_CALL] ERROR: callDocId is null or empty, cannot send notification');
      return;
    }

    debugPrint('📞 [STUDENT_CALL] CallDocId validated: $callDocId');

    final studentPhoto = ImageHelper.getValidImageUrl(
      currentUserModel?.imageUrl,
    );

    debugPrint('📞 [STUDENT_CALL] Student photo validated: $studentPhoto');
    debugPrint('📞 [STUDENT_CALL] Student name: ${currentUserModel?.name ?? 'طالب'}');
    debugPrint('📞 [STUDENT_CALL] Teacher UID: ${teacherModel.uid}');
    debugPrint('📞 [STUDENT_CALL] Student UID: ${currentUserModel?.uid ?? ''}');

    debugPrint('📱 [STUDENT_CALL] Sending incoming call notification to teacher');

    AppFirebaseNotification.pushIncomingCallNotification(
      callId: callDocId!,
      callerName: currentUserModel?.name ?? 'طالب',
      callerPhoto: studentPhoto,
      teacherUid: teacherModel.uid,
      studentUid: currentUserModel?.uid ?? '',
    );

    debugPrint('📱 [STUDENT_CALL] pushIncomingCallNotification() called');
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

  // ---------- Connection Timeout & Retry Logic ----------



  @override
  Future<void> close() {
    stopSound();
    _player.dispose();
    closeListener();
    _callTimeoutTimer?.cancel();
    maxCallDurationTimer?.cancel();
    _connectionEstablishmentTimer?.cancel();
    _clearPreComment();
    _callTimerController.close();
    stopCallTimer();
    _callSubscription?.cancel();
    callService.dispose();
    audioSessionService.dispose();
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
