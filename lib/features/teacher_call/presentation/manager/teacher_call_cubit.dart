import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/services/firebase_notification.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

part 'teacher_call_state.dart';

class TeacherCallCubit extends Cubit<TeacherCallState> {
  TeacherCallCubit({required this.teacherModel}) : super(TeacherCallInitial());

  final TeacherModel teacherModel;

  static TeacherCallCubit get(context) => BlocProvider.of(context);

  final db = FirebaseFirestore.instance;
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound() async {
    _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/phone-ringing.mp3'));
  }

  Future<void> stopSound() async {
    await _player.stop();
  }

  void initCall() async {
    await playSound();
    await sendCallToTeacher();
    callPushNotification();
    callListener();
    startCallTimeout();
    emit(SendCallToTeacherSuccess());
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

  Future<void> endCall({bool isByUser = false}) async {
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

  void callListener() {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(callDocId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            if (data != null && data['status'] == 'answered') {
              emit(CallAnsweredState());
              stopSound();
              _callTimeoutTimer?.cancel();
              if (data['meetingLink'] != null) {
                openMeet(data['meetingLink'].toString())
                    .then((value) {
                      emit(MeetingOpenedState());
                    })
                    .catchError((error) {
                      emit(SendCallToTeacherFailure(error: error.toString()));
                    });
              }
            } else if (data != null && data['status'] == 'declined') {
              emit(TeacherInAnotherCall());
            }
          }
        });
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
    // make a timer for 2 minutes to end the call if not answered even if the user closes the app
    _callTimeoutTimer = Timer(const Duration(minutes: 2), () {
      endCall();
    });
  }

  Future<void> openMeet(String url) async {
    final Uri meetUrl = Uri.parse(url);
    if (await canLaunchUrl(meetUrl)) {
      await launchUrl(meetUrl, mode: LaunchMode.externalApplication).catchError(
        (error) {
          printWithColor("catchError $error");
          return error;
        },
      );
    } else {
      printWithColor("else");
    }
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

  @override
  Future<void> close() {
    stopSound();
    _player.dispose();
    closeListener();
    _callTimeoutTimer?.cancel();
    return super.close();
  }
}
