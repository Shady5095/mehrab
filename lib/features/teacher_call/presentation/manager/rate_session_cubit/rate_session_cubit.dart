import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/core/utilities/services/firebase_notification.dart';
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

  GlobalKey<FormState> formKey = GlobalKey();

  void updateRating(double newRating) {
    rating = newRating;
    if (newRating == 0) {
      isStudentRated = false;
    } else {
      isStudentRated = true;
    }
    emit(RateSessionUpdated());
  }

  void selectPreFilledComment(String comment, double ratingValue) {
      commentController.text = comment;
    // Set cursor to end of text
    commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: commentController.text.length),
    );
    // Update rating
    updateRating(ratingValue);
    // Emit state to refresh UI
    emit(RateSessionUpdated());
  }

  String? record;

  String? qiraat;

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

  List<String> records = [
    "تصحيح تلاوة",
    "تسميع",
    "حفظ",
    "مراجعه",
    "تلقين",
    "اختبار",
    "إقراء وإجازة",
    "اخري",
  ];
  final List<String> qiraatList = [
    'قراءة نافع المدني',
    'قراءة ابن كثير',
    'قراءة ابن عامر',
    'قراءة أبي عمرو',
    'قراءة عاصم',
    'قراءة حمزة',
    'قراءة الكسائي',
    'قراءة أبي جعفر',
    'قراءة خلف البزار',
    'قراءة يعقوب',
  ];

  void changeRecord(String? value) {
    record = value;
    qiraat = null;
    emit(RateSessionInitial());
  }

  bool isStudentRated = true;

  bool checkIfStudentRated() {
    if (rating == 0) {
      emit(RateSessionInitial());
      isStudentRated = false;
      return false;
    } else {
      isStudentRated = true;
      return true;
    }
  }

  Timestamp? startTime;
  Timestamp? endTime;

  Future<void> updateSession() async {
    emit(RateSessionLoading());
    try {
      await db.collection('calls').doc(callModel.callId).update({
        'rating': rating,
        if (record != null) 'record': record,
        if (qiraat != null) 'qiraat': qiraat,
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
        if (startTime != null) 'answeredTime': startTime,
        if (endTime != null) 'endedTime': endTime,
        'status': 'ended',
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
    record = callModel.record?.trim();
    qiraat = callModel.qiraat;
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
      callModel.acceptedTime?.toDate()??DateTime.now(),
    );
    startTime = callModel.acceptedTime;
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

  final List<Map<String, dynamic>> surahs = const [
    {"name": "الفاتحة", "verses": 7},
    {"name": "البقرة", "verses": 286},
    {"name": "آل عمران", "verses": 200},
    {"name": "النساء", "verses": 176},
    {"name": "المائدة", "verses": 120},
    {"name": "الأنعام", "verses": 165},
    {"name": "الأعراف", "verses": 206},
    {"name": "الأنفال", "verses": 75},
    {"name": "التوبة", "verses": 129},
    {"name": "يونس", "verses": 109},
    {"name": "هود", "verses": 123},
    {"name": "يوسف", "verses": 111},
    {"name": "الرعد", "verses": 43},
    {"name": "إبراهيم", "verses": 52},
    {"name": "الحجر", "verses": 99},
    {"name": "النحل", "verses": 128},
    {"name": "الإسراء", "verses": 111},
    {"name": "الكهف", "verses": 110},
    {"name": "مريم", "verses": 98},
    {"name": "طه", "verses": 135},
    {"name": "الأنبياء", "verses": 112},
    {"name": "الحج", "verses": 78},
    {"name": "المؤمنون", "verses": 118},
    {"name": "النور", "verses": 64},
    {"name": "الفرقان", "verses": 77},
    {"name": "الشعراء", "verses": 227},
    {"name": "النمل", "verses": 93},
    {"name": "القصص", "verses": 88},
    {"name": "العنكبوت", "verses": 69},
    {"name": "الروم", "verses": 60},
    {"name": "لقمان", "verses": 34},
    {"name": "السجدة", "verses": 30},
    {"name": "الأحزاب", "verses": 73},
    {"name": "سبأ", "verses": 54},
    {"name": "فاطر", "verses": 45},
    {"name": "يس", "verses": 83},
    {"name": "الصافات", "verses": 182},
    {"name": "ص", "verses": 88},
    {"name": "الزمر", "verses": 75},
    {"name": "غافر", "verses": 85},
    {"name": "فصلت", "verses": 54},
    {"name": "الشورى", "verses": 53},
    {"name": "الزخرف", "verses": 89},
    {"name": "الدخان", "verses": 59},
    {"name": "الجاثية", "verses": 37},
    {"name": "الأحقاف", "verses": 35},
    {"name": "محمد", "verses": 38},
    {"name": "الفتح", "verses": 29},
    {"name": "الحجرات", "verses": 18},
    {"name": "ق", "verses": 45},
    {"name": "الذاريات", "verses": 60},
    {"name": "الطور", "verses": 49},
    {"name": "النجم", "verses": 62},
    {"name": "القمر", "verses": 55},
    {"name": "الرحمن", "verses": 78},
    {"name": "الواقعة", "verses": 96},
    {"name": "الحديد", "verses": 29},
    {"name": "المجادلة", "verses": 22},
    {"name": "الحشر", "verses": 24},
    {"name": "الممتحنة", "verses": 13},
    {"name": "الصف", "verses": 14},
    {"name": "الجمعة", "verses": 11},
    {"name": "المنافقون", "verses": 11},
    {"name": "التغابن", "verses": 18},
    {"name": "الطلاق", "verses": 12},
    {"name": "التحريم", "verses": 12},
    {"name": "الملك", "verses": 30},
    {"name": "القلم", "verses": 52},
    {"name": "الحاقة", "verses": 52},
    {"name": "المعارج", "verses": 44},
    {"name": "نوح", "verses": 28},
    {"name": "الجن", "verses": 28},
    {"name": "المزمل", "verses": 20},
    {"name": "المدثر", "verses": 56},
    {"name": "القيامة", "verses": 40},
    {"name": "الإنسان", "verses": 31},
    {"name": "المرسلات", "verses": 50},
    {"name": "النبأ", "verses": 40},
    {"name": "النازعات", "verses": 46},
    {"name": "عبس", "verses": 42},
    {"name": "التكوير", "verses": 29},
    {"name": "الإنفطار", "verses": 19},
    {"name": "المطففين", "verses": 36},
    {"name": "الإنشقاق", "verses": 25},
    {"name": "البروج", "verses": 22},
    {"name": "الطارق", "verses": 17},
    {"name": "الأعلى", "verses": 19},
    {"name": "الغاشية", "verses": 26},
    {"name": "الفجر", "verses": 30},
    {"name": "البلد", "verses": 20},
    {"name": "الشمس", "verses": 15},
    {"name": "الليل", "verses": 21},
    {"name": "الضحى", "verses": 11},
    {"name": "الشرح", "verses": 8},
    {"name": "التين", "verses": 8},
    {"name": "العلق", "verses": 19},
    {"name": "القدر", "verses": 5},
    {"name": "البينة", "verses": 8},
    {"name": "الزلزلة", "verses": 8},
    {"name": "العاديات", "verses": 11},
    {"name": "القارعة", "verses": 11},
    {"name": "التكاثر", "verses": 8},
    {"name": "العصر", "verses": 3},
    {"name": "الهمزة", "verses": 9},
    {"name": "الفيل", "verses": 5},
    {"name": "قريش", "verses": 4},
    {"name": "الماعون", "verses": 7},
    {"name": "الكوثر", "verses": 3},
    {"name": "الكافرون", "verses": 6},
    {"name": "النصر", "verses": 3},
    {"name": "المسد", "verses": 5},
    {"name": "الإخلاص", "verses": 4},
    {"name": "الفلق", "verses": 5},
    {"name": "الناس", "verses": 6},
  ];

  int getVerseCountBySurahName(String name) {
    final surah = surahs.firstWhere((s) => s['name'] == name, orElse: () => {});
    return surah.isNotEmpty ? surah['verses'] as int : 10000;
  }

  void setFromSurah(String surah) {
    fromSurahController.text = surah;
    toSurahController.text = surah;
    if (fromAyahController.text.isEmpty) {
      fromAyahController.text = '1';
    }
    toAyahController.clear();
    emit(RateSessionInitial());
  }

  void setToSurah(String surah) {
    toSurahController.text = surah;
    toAyahController.clear();
    emit(RateSessionInitial());
  }

  bool isSessionHasConnectionError = false;

  void checkIfConnectionError() {
    if (isEditMode) return;
    if (callModel.acceptedTime != null && callModel.endedTime != null) {
      Timestamp endedTime = callModel.endedTime!;
      Timestamp answeredTime = callModel.acceptedTime!;
      Duration difference = endedTime.toDate().difference(
        answeredTime.toDate(),
      );
      if (difference.inSeconds <= 120) {
        isSessionHasConnectionError = true;
        emit(RateSessionInitial());
      }
    }
  }

  Future<void> decrementTeacherCalls() async {
    try {
      final teacherRef = db.collection('users').doc(callModel.teacherUid);
      await teacherRef.update({
        'totalSessions': FieldValue.increment(-1),
      });
    } catch (e) {
      printWithColor(e.toString());
    }
  }

  Future<void> deleteSession() async {
    try {
      await db.collection('calls').doc(callModel.callId).delete();
    } catch (e) {
      printWithColor(e.toString());
    }
  }

  Future<void> notifyStudentToTryAgain() async {
    AppFirebaseNotification.pushNotification(
      title: "نأسف لقطع الاتصال يبدو ان هناك مشكله في الخادم",
      body: "يرجي اعادة الاتصال بالمُعلِّم ${callModel.teacherName.split(' ').take(2).join(' ')} مرة اخري",
      dataInNotification: {'type': 'call_connection_error'},
      topic: callModel.studentUid,
    );
    decrementTeacherCalls();
  }

  @override
  Future<void> close() {
    fromSurahController.dispose();
    toSurahController.dispose();
    fromAyahController.dispose();
    toAyahController.dispose();
    numberOfFacesController.dispose();
    wordErrorsController.dispose();
    theHesitationController.dispose();
    tajweedErrorsController.dispose();
    commentController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    return super.close();
  }
}
