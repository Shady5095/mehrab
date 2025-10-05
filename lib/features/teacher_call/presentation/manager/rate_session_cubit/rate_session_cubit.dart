import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:meta/meta.dart';

import '../../../../../core/widgets/show_date_time_picker.dart';

part 'rate_session_state.dart';

class RateSessionCubit extends Cubit<RateSessionState> {
  RateSessionCubit({required this.callModel, this.isEditMode = false})
    : super(RateSessionInitial());

  static RateSessionCubit instance(context) => BlocProvider.of(context);

  final CallModel callModel;

  final bool isEditMode;

  double rating = 0;

  final db = FirebaseFirestore.instance;

  void updateRating(double newRating) {
    rating = newRating;
    emit(RateSessionUpdated());
  }

  TextEditingController recordController = TextEditingController();
  TextEditingController fromSurahController = TextEditingController();
  TextEditingController toSurahController = TextEditingController();
  TextEditingController fromAyahController = TextEditingController();
  TextEditingController toAyahController = TextEditingController();
  TextEditingController numberOfFacesController = TextEditingController();
  TextEditingController wordErrorsController = TextEditingController();
  TextEditingController theHesitationController = TextEditingController();
  TextEditingController tajweedErrorsController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  Timestamp? startTime;
  Timestamp? endTime;

  Future<void> updateSession() async {
    emit(RateSessionLoading());
    try {
      await db.collection('calls').doc(callModel.callId).update({
        'rating': rating,
        if (recordController.text.isNotEmpty) 'record': recordController.text,
        if (fromSurahController.text.isNotEmpty)
          'fromSurah': fromSurahController.text,
        if (toSurahController.text.isNotEmpty)
          'toSurah': toSurahController.text,
        if (fromAyahController.text.isNotEmpty)
          'fromAyah': fromAyahController.text,
        if (toAyahController.text.isNotEmpty) 'toAyah': toAyahController.text,
        if (numberOfFacesController.text.isNotEmpty)
          'numberOfFaces': numberOfFacesController.text,
        if (wordErrorsController.text.isNotEmpty)
          'wordErrors': wordErrorsController.text,
        if (theHesitationController.text.isNotEmpty)
          'theHesitation': theHesitationController.text,
        if (tajweedErrorsController.text.isNotEmpty)
          'tajweedErrors': tajweedErrorsController.text,
        if (commentController.text.isNotEmpty)
          'comment': commentController.text,
        if (startTime != null) 'timestamp': startTime,
        if (endTime != null) 'endedTime': endTime,
      });
      emit(RateSessionSuccess());
    } catch (e) {
      printWithColor(e.toString());
      emit(RateSessionError(e.toString()));
    }
  }

  void fillControllersWithExistingData(BuildContext context) {
    if (!isEditMode) return;
    rating = callModel.rating?.toDouble() ?? 0;
    recordController.text = callModel.record ?? '';
    fromSurahController.text = callModel.fromSurah ?? '';
    toSurahController.text = callModel.toSurah ?? '';
    fromAyahController.text = callModel.fromAyah?.toString() ?? '';
    toAyahController.text = callModel.toAyah?.toString() ?? '';
    numberOfFacesController.text = callModel.numberOfFaces?.toString() ?? '';
    wordErrorsController.text = callModel.wordErrors?.toString() ?? '';
    theHesitationController.text = callModel.theHesitation?.toString() ?? '';
    tajweedErrorsController.text = callModel.tajweedErrors?.toString() ?? '';
    commentController.text = callModel.comment ?? '';
    startTimeController.text = formatDateTimePicker(
      context,
      callModel.timestamp.toDate(),
    );
    startTime = callModel.timestamp;
    if (callModel.endedTime == null) {
      endTimeController.text = '';
      endTime = null;
    } else {
      endTimeController.text = formatDateTimePicker(
        context,
        callModel.endedTime!.toDate(),
      );
      endTime = callModel.endedTime;
    }
  }
}
