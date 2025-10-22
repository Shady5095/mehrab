import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

part 'calls_state.dart';

class CallsCubit extends Cubit<CallsState> {
  CallsCubit() : super(CallsInitial());

  static CallsCubit get(context) => BlocProvider.of(context);

  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> endCall(String callId,String studentUid, String teacherName) async {
    try {
      await db.collection('calls').doc(callId).update({'status': 'ended'});
      emit(EndCallSuccess());
    } catch (e) {
      emit(EndCallError(e.toString()));
    }
  }
  Future<void> openMeet(String url) async {
    final Uri meetUrl = Uri.parse(url);
    if (await canLaunchUrl(meetUrl)) {
      await launchUrl(meetUrl, mode: LaunchMode.externalApplication);
    }
  }
}
