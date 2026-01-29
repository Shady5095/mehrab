import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_off/screen_off.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/utilities/services/call_foreground_service.dart';
import '../../../../../core/utilities/services/livekit_call_service.dart';
import '../../../../../core/utilities/services/audio_session_service.dart';
import '../../../../../core/utilities/services/firebase_notification.dart';
part 'teacher_call_state.dart';

class TeacherCallCubit extends Cubit<TeacherCallState> {
  final CallModel callModel;
  TeacherCallCubit({
    required this.callModel,
  }) : super(TeacherCallInitial());

  static TeacherCallCubit get(BuildContext context) => BlocProvider.of(context);

  late LiveKitCallService callService;
  late AudioSessionService audioSessionService;

  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();

  String? remoteUid;

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
  bool isSpeakerOn = true;
  bool isVideoEnabled = false;
  bool isRemoteVideoEnabled = false;

  Future<void> setupLiveKitCallService() async {
    debugPrint('🔧 Teacher setting up LiveKit call service');
    callService = LiveKitCallService();
    audioSessionService = AudioSessionService();

    // Configure audio session
    await audioSessionService.configureForCall();

    callService.onUserJoined = (participantId) {
      debugPrint('👥 Teacher: User joined LiveKit room: $participantId');
      remoteUid = participantId;
    };

    callService.onUserLeft = (participantId) async {
      debugPrint('👋 Teacher: User left LiveKit room: $participantId');
      await endCall();
    };

    callService.onError = (error) {
      debugPrint('❌ Teacher LiveKit error: $error');
      emit(AgoraConnectionError(error: error));
    };

    callService.onCallEnded = () {
      debugPrint('📞 Teacher LiveKit call ended');
    };

    callService.onConnectionSuccess = () {
      debugPrint('🔗 Teacher LiveKit connection successful');
      startCallTimer();
      isCallConnected = true;
      playAnswerSound();
      HapticFeedback.vibrate();
      if (Platform.isIOS) {
        callService.switchSpeaker(true);
      }
      // Ensure audio session is active
      audioSessionService.setActive(true);
      initCallListener(); // Start listening for pre-comments
      emit(TeacherCallInitial());
    };

    callService.onRemoteVideoStateChanged = (participantId, enabled) {
      debugPrint('📹 Teacher remote video state changed for $participantId: $enabled');
      isRemoteVideoEnabled = enabled;
      emit(RemoteVideoStateChanged());
    };

    await callService.initialize();
    debugPrint('✅ Teacher LiveKit call service initialized');
  }

  Future<void> connectToLiveKitRoom() async {
    debugPrint('🔄 Teacher attempting to connect to LiveKit room: ${callModel.callId}');
    try {
      // Get LiveKit token from server
      final token = await _getLiveKitToken();
      if (token == null) {
        debugPrint('❌ Teacher failed to get LiveKit token - token is null');
        emit(AgoraConnectionError(error: 'Failed to get LiveKit token'));
        return;
      }

      debugPrint('✅ Teacher got LiveKit token, connecting to room...');
      // Connect to LiveKit room
      await callService.connect(token, callModel.callId);
      debugPrint('✅ Teacher LiveKit connect method called successfully');
    } catch (error) {
      debugPrint('❌ Teacher failed to connect to LiveKit room: $error');
      emit(AgoraConnectionError(error: 'Failed to connect to LiveKit room: $error'));
    }
  }

  Future<String?> _getLiveKitToken() async {
    try {
      // Get Firebase auth token (try cached first, refresh if expired)
      String? authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      
      // Check if token is expired, if so force refresh
      if (authToken != null && _isTokenExpired(authToken)) {
        debugPrint('🔄 Firebase token expired, forcing refresh...');
        authToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      }

      // Call the server's /token endpoint with timeout
      final response = await Dio().post(
        '${AppConfig.signalingServerUrl}/api/livekit/token',
        data: {
          'roomName': callModel.callId,
          'participantName': callModel.teacherName,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          // Add timeout for faster failure detection
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
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

  /// Check if Firebase ID token is expired by decoding JWT
  bool _isTokenExpired(String token) {
    try {
      // JWT has 3 parts separated by '.'
      final parts = token.split('.');
      if (parts.length != 3) return true; // Invalid token format
      
      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      
      // Parse JSON
      final payloadMap = json.decode(decodedPayload);
      
      // Get expiration time (exp claim)
      final exp = payloadMap['exp'];
      if (exp == null) return true; // No expiration claim
      
      // Convert to DateTime and check if expired
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      // Add 5 minute buffer to account for clock skew
      final bufferTime = now.add(const Duration(minutes: 5));
      
      return bufferTime.isAfter(expirationDate);
    } catch (e) {
      debugPrint('Error checking token expiration: $e');
      // If we can't decode, assume it's expired to be safe
      return true;
    }
  }



  /// Creates and sends an answer with retry logic


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
    debugPrint('🔊 Teacher switching speaker. Current state: $isSpeakerOn');
    await callService.switchSpeaker(!callService.isSpeakerOn);
    isSpeakerOn = callService.isSpeakerOn;
    debugPrint('🔊 Teacher speaker switched. New state: $isSpeakerOn');
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
    callService.dispose();
    audioSessionService.dispose();
    if (Platform.isAndroid) {
      disableProximitySensor();
      CallForegroundService.stopCallService();
    }
    return super.close();
  }
}
