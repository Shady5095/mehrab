import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/services/firebase_notification.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:flutter/material.dart';

part 'calls_state.dart';

class CallsCubit extends Cubit<CallsState> {
  CallsCubit() : super(CallsInitial());

  static CallsCubit get(BuildContext context) => BlocProvider.of(context);

  FirebaseFirestore db = FirebaseFirestore.instance;
  Future<void> notifyStudentToCallAgain(CallModel model) async {
    AppFirebaseNotification.pushNotification(
      title: "نأسف لعدم الرد من المعلم",
      body: "المُعلِّم ${model.teacherName.split(' ').take(2).join(' ')} متاح🟢, عاود الاتصال به الان",
      dataInNotification: {},
      topic: model.studentUid,
    );
    markAsNotified(model.callId);
  }
  Future<void> markAsNotified(String callId) async {
    await db.collection('calls').doc(callId).update({
      'notifiedToCallAgain': true,
    });
  }
}
