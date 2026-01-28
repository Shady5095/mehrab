import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_off/screen_off.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/utilities/services/call_foreground_service.dart';
import '../../../../../core/utilities/services/livekit_call_service.dart';
import '../../../../../core/utilities/services/livekit_token_service.dart';
import '../../../../../core/utilities/services/audio_session_service.dart';
import '../../../../../core/utilities/services/firebase_notification.dart';
import '../../../../../core/utilities/functions/dependency_injection.dart';
part 'teacher_call_state.dart';

class TeacherCallCubit extends Cubit<TeacherCallState> {
  final CallModel callModel;
  TeacherCallCubit({
    required this.callModel,
  }) : super(TeacherCallInitial());

  static TeacherCallCubit get(BuildContext context) => BlocProvider.of(context);

  late LiveKitCallService callService;
  late AudioSessionService audioSessionService;
  final LiveKitTokenService _tokenService = getIt<LiveKitTokenService>();

  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();

  Future<void> requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> makeTeacherBusy() async {
    final userRef = db.collection('users').doc(callModel.teacherUid);
    await userRef.update({
      'isBusy': true,
    });
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
      await CallForegroundService.init(silentMode: true);
      await Future.delayed(Duration(milliseconds: 300));
    }
    makeTeacherBusy();
    await setupLiveKitCallService();
    await connectToLiveKitRoom();
  }

  Future<void> endCall() async {
    try {
      _clearPreComment();
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
        callService.endCall(),
        AppFirebaseNotification.endCall(callModel.callId),
      ]);
      emit(CallFinished());
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

  CallModel? latestCallData;
  void initCallListener() {
    _callSubscription?.cancel();
    _callSubscription = db
        .collection('calls')
        .doc(callModel.callId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        latestCallData = CallModel.fromJson(snapshot.data() ?? {});
        CallModel data = CallModel.fromJson(snapshot.data() ?? {});

        // Listen for pre-comments (only if call is connected and not ended)
        if (isCallConnected &&
            data.status != 'ended' &&
            data.status != 'missed') {
          final preComment = snapshot.data()?['preComment'] as String?;

          if (preComment != null && preComment != currentPreComment) {
            currentPreComment = preComment;
            HapticFeedback.vibrate();
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

  bool isCallConnected = false;
  bool isMicMuted = false;
  bool isSpeakerOn = false;
  bool isVideoEnabled = false;
  bool isRemoteVideoEnabled = false;
  String? remoteUid;

  Future<void> setupLiveKitCallService() async {
    callService = LiveKitCallService();
    audioSessionService = AudioSessionService();

    // Configure audio session for proper audio routing
    await audioSessionService.configureForCall();

    callService.onUserJoined = (peerId) {
      remoteUid = peerId;
      startCallTimer();
      isCallConnected = true;
      playAnswerSound();
      HapticFeedback.vibrate();
      initCallListener();
      emit(TeacherCallInitial());
    };

    callService.onUserLeft = (peerId) async {
      await endCall();
    };

    callService.onError = (error) {
      emit(AgoraConnectionError(error: error));
    };

    callService.onCallEnded = () {};

    callService.onConnectionSuccess = () {
      debugPrint('Teacher: LiveKit connection successful');
    };

    callService.onRemoteVideoStateChanged = (peerId, enabled) {
      isRemoteVideoEnabled = enabled;
      emit(RemoteVideoStateChanged());
    };

    callService.onConnectionRecovering = () {
      debugPrint('Teacher: Connection recovering...');
      emit(ConnectionRecovering());
    };

    callService.onNetworkQualityChanged = (quality) {
      debugPrint('Teacher: Network quality changed to ${quality.name}');
      emit(NetworkQualityChanged(quality: quality));
    };

    await callService.initialize();
  }

  Future<void> connectToLiveKitRoom() async {
    try {
      final authToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (authToken == null) {
        emit(AgoraConnectionError(error: 'Authentication failed'));
        return;
      }

      // Fetch LiveKit token from backend
      final livekitToken = await _tokenService.fetchToken(
        roomName: callModel.callId,
        participantName: callModel.teacherName,
        authToken: authToken,
      );

      if (livekitToken == null) {
        emit(AgoraConnectionError(error: 'Failed to get room token'));
        return;
      }

      // Connect to LiveKit room
      await callService.connectToRoom(
        serverUrl: AppConfig.livekitServerUrl,
        token: livekitToken,
        roomName: callModel.callId,
      );

      debugPrint('Teacher: Connected to LiveKit room');
    } catch (e) {
      debugPrint('Teacher: Error connecting to LiveKit: $e');
      emit(AgoraConnectionError(error: 'Failed to connect: $e'));
    }
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
    final newSpeakerState = !callService.isSpeakerOn;

    if (Platform.isIOS) {
      if (newSpeakerState) {
        await audioSessionService.switchToSpeaker();
      } else {
        await audioSessionService.switchToEarpiece();
      }
    }

    await Future.delayed(const Duration(milliseconds: 50));

    await callService.switchSpeaker(newSpeakerState);
    isSpeakerOn = callService.isSpeakerOn;

    if (Platform.isAndroid) {
      if (!isSpeakerOn && !isVideoEnabled) {
        enableProximitySensor();
      } else {
        disableProximitySensor();
      }
    }

    HapticFeedback.heavyImpact();
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

    if (Platform.isAndroid) {
      CallForegroundService.startCallService(
        callerName: callModel.studentName,
        callDuration: _formatDuration(_elapsedTime),
        silentMode: true,
      );
    }

    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      final formattedTime = _formatDuration(_elapsedTime);
      _callTimerController.add(formattedTime);
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

  Future<void> sendPreComment(String comment) async {
    try {
      await db.collection('calls').doc(callModel.callId).update({
        'preComment': comment,
        'preCommentTimestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      emit(AgoraConnectionError(error: 'فشل إرسال التعليق: $error'));
    }
  }

  final List<String> preComments = [
    'ما شاء الله 🌿',
    'ممتاز جدًا 👏',
    'أحسنت التلاوة 📖',
    'رائع، استمر 🌟',
    'أداء طيب 👍',
    'قراءة جميلة ✨',
    'حفظ ممتاز 💜',
    'تقدم رائع 💙',
    'بارك الله فيك 💚',
    'أحسنت، واصل 💪',
    'تلاوة مباركة 🌙',
    'جميل جدًا ⭐',
    'صوت هادئ وجميل ❤️',
    'إتقان واضح 👌',
    'إنتبه ⚠️',
    'تجويد ممتاز 🎵',
  ];

  @override
  Future<void> close() {
    stopSound();
    _player.dispose();
    _callTimerController.close();
    stopCallTimer();
    _clearPreComment();
    _callSubscription?.cancel();
    callService.dispose();
    audioSessionService.dispose();
    if (Platform.isAndroid) {
      disableProximitySensor();
      CallForegroundService.stopCallService();
    }
    return super.close();
  }
}
