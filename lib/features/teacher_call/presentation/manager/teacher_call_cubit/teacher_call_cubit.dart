import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_off/screen_off.dart';

import '../../../../../core/utilities/services/call_foreground_service.dart';
import '../../../../../core/utilities/services/webrtc_call_service.dart';
import '../../../../../core/utilities/services/socket_service.dart';
import '../../../../../core/utilities/services/turn_credential_service.dart';
import '../../../../../core/utilities/services/audio_session_service.dart';
import '../../../../../core/utilities/services/webrtc_constants.dart';
import '../../../../../core/utilities/services/firebase_notification.dart';
import '../../../../../core/utilities/functions/dependency_injection.dart';
part 'teacher_call_state.dart';

class TeacherCallCubit extends Cubit<TeacherCallState> {
  final CallModel callModel;
  TeacherCallCubit({
    required this.callModel,
  }) : super(TeacherCallInitial());

  static TeacherCallCubit get(context) => BlocProvider.of(context);

  late WebRTCCallService callService;
  late SocketService socketService;
  late AudioSessionService audioSessionService;
  final TurnCredentialService _turnService = getIt<TurnCredentialService>();

  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();

  String? _remoteSocketId;
  final List<RTCIceCandidate> _pendingCandidates = [];

  Future<void> requestPermissions() async {
    // check and request microphone permission
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
      // 🆕 Initialize في silent mode للمعلم
      await CallForegroundService.init(silentMode: true);
      await Future.delayed(Duration(milliseconds: 300));
    }
    makeTeacherBusy();
    await setupWebRTCCallService();
    await connectToSignalingServer();
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
        endWebRTCCall(),
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
  bool isSpeakerOn = true;
  bool isVideoEnabled = false;
  bool isRemoteVideoEnabled = false;
  String? remoteUid;

  Future<void> setupWebRTCCallService() async {
    callService = WebRTCCallService();
    audioSessionService = AudioSessionService();

    // Configure audio session
    await audioSessionService.configureForCall();

    // Fetch TURN credentials
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (authToken != null) {
      final iceConfig = await _turnService.fetchCredentials(authToken);
      if (iceConfig != null) {
        callService.setIceServers(iceConfig);
      }
    }

    callService.onUserJoined = (peerId) {
      remoteUid = peerId;
    };

    callService.onUserLeft = (peerId) async {
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
      initCallListener(); // Start listening for pre-comments
      emit(TeacherCallInitial());
    };

    callService.onRemoteVideoStateChanged = (peerId, enabled) {
      isRemoteVideoEnabled = enabled;
      emit(RemoteVideoStateChanged());
    };

    callService.onIceCandidate = (candidate) {
      if (_remoteSocketId != null) {
        socketService.sendIceCandidate(candidate, _remoteSocketId!);
      } else {
        _pendingCandidates.add(candidate);
      }
    };

    await callService.initialize();
  }

  Future<void> connectToSignalingServer() async {
    socketService = SocketService();

    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (authToken == null) {
      emit(AgoraConnectionError(error: 'Authentication failed'));
      return;
    }

    socketService.onConnected = () {
      debugPrint('Teacher: Connected to signaling server');
      // Join the room immediately when connected
      socketService.joinRoom(callModel.callId);
    };

    socketService.onError = (error) {
      debugPrint('Teacher: Socket error: $error');
      emit(AgoraConnectionError(error: error));
    };

    // Handle offer from student
    socketService.onOfferReceived = (offer, fromSocketId, fromUid) async {
      debugPrint('Teacher: Received offer from student');
      _remoteSocketId = fromSocketId;

      // Send any pending ICE candidates
      for (var candidate in _pendingCandidates) {
        socketService.sendIceCandidate(candidate, fromSocketId);
      }
      _pendingCandidates.clear();

      // Create and send answer
      try {
        final answer = await callService.createAnswer(offer);
        socketService.sendAnswer(answer, fromSocketId);
      } catch (e) {
        emit(AgoraConnectionError(error: 'Failed to create answer: $e'));
      }
    };

    // Handle ICE candidates from student
    socketService.onIceCandidateReceived = (candidate, fromSocketId) {
      callService.addIceCandidate(candidate);
    };

    socketService.onUserLeft = (odId, socketId) async {
      debugPrint('Teacher: Student left');
      await endCall();
    };

    await socketService.connect(
      WebRTCConstants.signalingServerUrl,
      authToken,
    );
  }

  Future<void> endWebRTCCall() async {
    socketService.leaveRoom(callModel.callId);
    await socketService.disconnect();
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
    socketService.dispose();
    callService.dispose();
    audioSessionService.dispose();
    if (Platform.isAndroid) {
      disableProximitySensor();
      CallForegroundService.stopCallService();
    }
    return super.close();
  }
}
