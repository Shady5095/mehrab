import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/services/firebase_notification.dart';
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
import '../../../../../core/utilities/services/webrtc_call_service.dart';
import '../../../../../core/utilities/services/socket_service.dart';
import '../../../../../core/utilities/services/turn_credential_service.dart';
import '../../../../../core/utilities/services/audio_session_service.dart';
import '../../../../../core/utilities/functions/dependency_injection.dart';

class StudentCallCubit extends Cubit<StudentCallState> {
  StudentCallCubit({required this.teacherModel}) : super(TeacherCallInitial());

  final TeacherModel teacherModel;

  static StudentCallCubit get(BuildContext context) => BlocProvider.of(context);

  late WebRTCCallService callService;
  late SocketService socketService;
  late AudioSessionService audioSessionService;
  final TurnCredentialService _turnService = getIt<TurnCredentialService>();

  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();
  static const _uuid = Uuid();

  String? _remoteSocketId;
  final List<RTCIceCandidate> _pendingCandidates = [];

  // Connection timeout handling
  Timer? _connectionEstablishmentTimer;
  static const Duration _connectionTimeout = Duration(seconds: 20);

  // Retry logic
  static const int _maxOfferRetries = 3;
  static const Duration _offerRetryDelay = Duration(seconds: 2);

  // Network quality tracking
  CallQuality _lastNetworkQuality = CallQuality.good;

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
      await setupWebRTCCallService();
      await connectToSignalingServer();
      callPushNotification();
      callListener();
      startCallTimeout();
      emit(SendCallToTeacherSuccess());
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
      final endCallWebRTC = endWebRTCCall();
      await Future.wait([updateCall, endCallWebRTC]);
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
    isCallAnswered = true;
    emit(CallAnsweredState());
    stopSound();
    await Future.delayed(Duration(milliseconds: 300));
    _callTimeoutTimer?.cancel();
    // Join the signaling room when teacher answers
    socketService.joinRoom(data.callId);
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
  String? remoteUid;

  Future<void> setupWebRTCCallService() async {
    callService = WebRTCCallService();
    audioSessionService = AudioSessionService();

    // Configure audio session
    await audioSessionService.configureForCall();

    // Fetch TURN credentials
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (authToken != null) {
      final iceConfig = await _turnService.fetchCredentials(authToken);
      if (iceConfig != null) {
        callService.setIceServers(iceConfig);
      }
    }

    callService.onUserJoined = (peerId) {
      // Cancel connection timeout since we're connected
      _connectionEstablishmentTimer?.cancel();
      isAnotherUserJoined = true;
      remoteUid = peerId;
      startCallTimer();
      playAnswerSound();
      HapticFeedback.vibrate();
      if (Platform.isIOS) {
        callService.switchSpeaker(true);
      }
      emit(AnotherUserJoinedSuccessfully());
    };

    callService.onUserLeft = (peerId) async {
      if (!isCallEnded) {
        await endCallAfterAnswer(isByUser: false);
      } else {
        emit(AnotherUserLeft());
      }
    };

    callService.onError = (error) {
      emit(AgoraConnectionError(error: error));
    };

    callService.onCallEnded = () {};

    callService.onConnectionSuccess = () {
      // Cancel connection timeout on successful ICE connection
      _connectionEstablishmentTimer?.cancel();
    };

    // Handle ICE restart request (for network recovery)
    callService.onIceRestartNeeded = () async {
      if (_remoteSocketId != null) {
        debugPrint('Student: ICE restart requested, creating new offer');
        try {
          final offer = await callService.createIceRestartOffer();
          socketService.sendOffer(offer, _remoteSocketId!);
        } catch (e) {
          debugPrint('Student: ICE restart offer failed: $e');
          emit(AgoraConnectionError(error: 'فشل استعادة الاتصال. جاري المحاولة...'));
        }
      }
    };

    // Handle connection recovery state
    callService.onConnectionRecovering = () {
      emit(ConnectionRecovering());
    };

    // Handle network quality changes
    callService.onNetworkQualityChanged = (quality) {
      _lastNetworkQuality = quality;
      emit(NetworkQualityChanged(quality: quality));
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

    callService.onRenegotiationOffer = (offer) {
      if (_remoteSocketId != null) {
        socketService.sendOffer(offer, _remoteSocketId!);
        debugPrint('Student: Sent renegotiation offer');
      }
    };

    await callService.initialize();
  }

  Future<void> connectToSignalingServer() async {
    socketService = SocketService();

    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (authToken == null) {
      emit(AgoraConnectionError(error: 'Authentication failed'));
      return;
    }

    socketService.onConnected = () {
      debugPrint('Student: Connected to signaling server');
    };

    socketService.onReconnected = () async {
      debugPrint('Student: Socket reconnected to signaling server');
      // Clear the remote socket ID - it will be updated when we get new signaling
      _remoteSocketId = null;
      _pendingCandidates.clear();

      // DON'T reset WebRTC - it's peer-to-peer and might still be alive!
      // We'll create a new offer only when user-joined is received
      debugPrint('Student: WebRTC connection may still be alive (P2P)');
    };

    // Handle room joined - check if teacher is already in the room
    socketService.onRoomJoined = (callId, participants) async {
      debugPrint('Student: Room joined with ${participants.length} existing participants');
      if (participants.isNotEmpty) {
        // Teacher is already in the room
        final teacherParticipant = participants.first;
        final newSocketId = teacherParticipant['socketId'] as String;
        final oldSocketId = _remoteSocketId;
        _remoteSocketId = newSocketId;

        debugPrint('Student: Teacher already in room (socketId: $newSocketId)');

        // Send any pending ICE candidates
        for (var candidate in _pendingCandidates) {
          socketService.sendIceCandidate(candidate, newSocketId);
        }
        _pendingCandidates.clear();

        // Check if this is a reconnection scenario
        final isReconnection = oldSocketId != null && oldSocketId != newSocketId;
        final needsNewOffer = await callService.needsReconnection();

        if (needsNewOffer || isReconnection) {
          debugPrint('Student: Creating offer (needsNew: $needsNewOffer, isReconnection: $isReconnection)');
          // Start connection timeout
          _startConnectionTimeout();
          // Create offer with retry logic
          await _createAndSendOfferWithRetry(newSocketId, isReconnection);
        } else {
          debugPrint('Student: WebRTC still alive, no need to renegotiate');
        }
      }
    };

    socketService.onDisconnected = () {
      debugPrint('Student: Socket disconnected, waiting for reconnection...');
      // Don't end call immediately - socket will attempt to reconnect
      // Only show error if reconnection fails (handled by onError)
    };

    socketService.onError = (error) {
      debugPrint('Student: Socket error: $error');
      // Only emit error if it's not a temporary disconnection
      if (!error.contains('reconnect')) {
        emit(AgoraConnectionError(error: error));
      }
    };

    // When teacher joins the room, create and send offer
    socketService.onUserJoined = (odId, socketId) async {
      debugPrint('Student: Teacher joined with socketId: $socketId');
      final oldSocketId = _remoteSocketId;
      _remoteSocketId = socketId;

      // Send any pending ICE candidates to new socket
      for (var candidate in _pendingCandidates) {
        socketService.sendIceCandidate(candidate, socketId);
      }
      _pendingCandidates.clear();

      // Check if this is a reconnection (we had a previous socket ID)
      final isReconnection = oldSocketId != null && oldSocketId != socketId;

      // Check if WebRTC connection needs to be re-established
      final needsNewOffer = await callService.needsReconnection();

      if (needsNewOffer || isReconnection) {
        debugPrint('Student: Creating new offer (needsNew: $needsNewOffer, isReconnection: $isReconnection)');
        // Start connection timeout
        _startConnectionTimeout();
        // Create offer with retry logic
        await _createAndSendOfferWithRetry(socketId, isReconnection);
      } else {
        debugPrint('Student: WebRTC still alive, just updated remote socket ID');
      }
    };

    // Handle answer from teacher
    socketService.onAnswerReceived = (answer, fromSocketId, fromUid) async {
      debugPrint('Student: Received answer from teacher');
      try {
        await callService.setRemoteAnswer(answer);
      } catch (e) {
        emit(AgoraConnectionError(error: 'Failed to set answer: $e'));
      }
    };

    // Handle ICE candidates from teacher
    socketService.onIceCandidateReceived = (candidate, fromSocketId) {
      callService.addIceCandidate(candidate);
    };

    // Handle video state changes from teacher
    socketService.onVideoStateChanged = (enabled, fromSocketId) {
      debugPrint('Student: Teacher video state changed: $enabled');
      isRemoteVideoEnabled = enabled;
      if (enabled) {
        callService.remoteRenderer.srcObject = callService.remoteStream;
      } else {
        callService.remoteRenderer.srcObject = null;
      }
      emit(RemoteVideoStateChanged());
    };

    socketService.onUserLeft = (odId, socketId) async {
      debugPrint('Student: Teacher left');
      await endCallAfterAnswer(isByUser: false);
    };

    await socketService.connect(
      AppConfig.signalingServerUrl,
      authToken,
    );
  }

  Future<void> endWebRTCCall() async {
    socketService.leaveRoom(callDocId ?? '');
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

      // Send video state to remote peer
      if (_remoteSocketId != null) {
        socketService.sendVideoState(isVideoEnabled, _remoteSocketId!);
      }

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

  // ---------- Connection Timeout & Retry Logic ----------

  void _startConnectionTimeout() {
    _connectionEstablishmentTimer?.cancel();
    _connectionEstablishmentTimer = Timer(_connectionTimeout, () {
      if (!isAnotherUserJoined) {
        debugPrint('Student: Connection establishment timeout');
        emit(AgoraConnectionError(
          error: 'انتهت مهلة الاتصال. المعلم لم يستجب.',
        ));
      }
    });
  }

  void _cancelConnectionTimeout() {
    _connectionEstablishmentTimer?.cancel();
    _connectionEstablishmentTimer = null;
  }

  Future<void> _createAndSendOfferWithRetry(
    String socketId,
    bool forceNew, [
    int attempt = 1,
  ]) async {
    try {
      debugPrint('Student: Creating offer (attempt $attempt/$_maxOfferRetries)');
      // On retry attempts, always force a new peer connection since the previous one may be in a bad state
      final shouldForceNew = forceNew || attempt > 1;
      final offer = await callService.createOffer(forceNew: shouldForceNew)
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Offer creation timeout');
        },
      );
      socketService.sendOffer(offer, socketId);
      debugPrint('Student: Offer sent successfully');
    } catch (e) {
      debugPrint('Student: Offer creation failed: $e');
      if (attempt < _maxOfferRetries) {
        debugPrint('Student: Retrying in ${_offerRetryDelay.inSeconds}s...');
        await Future.delayed(_offerRetryDelay * attempt);
        // Check if still connected
        if (socketService.isConnected && _remoteSocketId != null) {
          await _createAndSendOfferWithRetry(socketId, forceNew, attempt + 1);
        }
      } else {
        emit(AgoraConnectionError(
          error: 'فشل إنشاء الاتصال بعد عدة محاولات. الرجاء المحاولة مرة أخرى.',
        ));
      }
    }
  }

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
    socketService.dispose();
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
