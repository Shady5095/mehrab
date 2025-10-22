import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../core/utilities/services/call_service.dart';
part 'teacher_call_state.dart';

class TeacherCallCubit extends Cubit<TeacherCallState> {
  final CallModel callModel;
  TeacherCallCubit({
    required this.callModel,
}) : super(TeacherCallInitial());

  static TeacherCallCubit get(context) => BlocProvider.of(context);

  late AgoraCallService callService ;
  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();
  Future<void> requestPermissions() async {
    // check and request microphone permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
      if(await Permission.microphone.isGranted == false){
        emit(AgoraConnectionError(error: "لم يتم منح إذن الميكروفون"));
      }
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
    await requestPermissions();
    await Future.delayed(Duration(
        milliseconds: 300
    ));
    await playAnswerSound();
    await setupAgoraCallService();
    joinAgoraChannel(callModel.callId);
  }

  Future<void> endCall() async {
      await db
          .collection('calls')
          .doc(callModel.callId)
          .update({'status': 'ended',"endedTime" : FieldValue.serverTimestamp()})
          .then((value) async {
        await endAgoraCall();
        emit(CallFinished());
      })
          .catchError((error) {
        emit(SendCallToTeacherFailure(error: error.toString()));
      });
  }
  StreamSubscription<DocumentSnapshot>? _callSubscription;

  Future<void> onTeacherAnswer(CallModel data) async {
    emit(CallAnsweredState());
    stopSound();
    await Future.delayed(Duration(
        milliseconds: 300
    ));
    playAnswerSound();
    HapticFeedback.heavyImpact();
    joinAgoraChannel(data.callId);
  }
  bool isCallConnected = false;
  bool isMicMuted = false;
  bool isSpeakerOn = false;
  Future<void> setupAgoraCallService() async {
    callService = AgoraCallService();
    callService.onUserJoined = (uid) {};
    callService.onUserLeft = (uid) async {
      await endCall();
    };
    callService.onError = (error) {
      emit(AgoraConnectionError(error: error));
    };
    callService.onCallEnded = () {

    };
    callService.onConnectionSuccess = () {
      startCallTimer();
      isCallConnected = true;
      emit(TeacherCallInitial());
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
    emit(TeacherCallInitial());
  }

  Future<void> switchSpeaker() async {
    await callService.switchSpeaker(!callService.isSpeakerOn);
    isSpeakerOn = callService.isSpeakerOn;
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

    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      _callTimerController.add(_formatDuration(_elapsedTime));
    });
  }

  void stopCallTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
  }

  @override
  Future<void> close() {
    stopSound();
    _player.dispose();
    _callTimerController.close();
    stopCallTimer();
    _callSubscription?.cancel();
    return super.close();
  }
}
