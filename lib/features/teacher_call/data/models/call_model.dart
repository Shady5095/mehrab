import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String callId;
  final String teacherUid;
  final Timestamp timestamp;
  final String studentUid;
  final String studentName;
  final String teacherName;
  final String? studentPhoto;
  final String? teacherPhoto;
  final String status;
  final String? meetingLink;
  final Timestamp? acceptedTime;
  final Timestamp? endedTime;
  final num? rating;
  final String? record;
  final String? fromSurah;
  final String? toSurah;
  final String? fromAyah;
  final String? toAyah;
  final String? numberOfFaces;
  final String? wordErrors;
  final String? theHesitation;
  final String? tajweedErrors;
  final String? comment;
  final String? qiraat;
  final bool? notifiedToCallAgain;


  CallModel({
    required this.callId,
    required this.teacherUid,
    required this.timestamp,
    required this.studentUid,
    required this.studentName,
    required this.teacherName,
    this.studentPhoto,
    this.teacherPhoto,
    this.meetingLink,
    required this.status,
    this.acceptedTime,
    this.endedTime,
    this.rating,
    this.record,
    this.fromSurah,
    this.toSurah,
    this.fromAyah,
    this.toAyah,
    this.numberOfFaces,
    this.wordErrors,
    this.theHesitation,
    this.tajweedErrors,
    this.comment,
    this.qiraat,
    this.notifiedToCallAgain,
  });

  factory CallModel.fromJson(Map<String, dynamic> map) {
    return CallModel(
      callId: map['callId'] ?? '',
      teacherUid: map['teacherUid'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      teacherName: map['teacherName'] ?? '',
      studentPhoto: map['studentPhoto'],
      teacherPhoto: map['teacherPhoto'],
      status: map['status'] ?? '',
      meetingLink: map['meetingLink'],
      acceptedTime: map['answeredTime']??map['acceptedTime'],
      rating: map['rating'],
      endedTime: map['endedTime'],
      record: map['record'],
      fromSurah: map['fromSurah'],
      toSurah: map['toSurah'],
      fromAyah: map['fromAyah'],
      toAyah: map['toAyah'],
      numberOfFaces: map['numberOfFaces'],
      wordErrors: map['wordErrors'],
      theHesitation: map['theHesitation'],
      tajweedErrors: map['tajweedErrors'],
      comment: map['comment'],
      qiraat: map['qiraat'],
      notifiedToCallAgain: map['notifiedToCallAgain']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'teacherUid': teacherUid,
      'timestamp': timestamp,
      'studentUid': studentUid,
      'studentName': studentName,
      'teacherName': teacherName,
      'studentPhoto': studentPhoto,
      'teacherPhoto': teacherPhoto,
      'status': status,
    };
  }
  // add copyWith method
  CallModel copyWith({
    String? callId,
    String? teacherUid,
    Timestamp? timestamp,
    String? studentUid,
    String? studentName,
    String? teacherName,
    String? studentPhoto,
    String? teacherPhoto,
    String? status,
    String? meetingLink,
    Timestamp? acceptedTime,
    Timestamp? endedTime,
    num? rating,
    String? record,
    String? fromSurah,
    String? toSurah,
    String? fromAyah,
    String? toAyah,
    String? numberOfFaces,
    String? wordErrors,
    String? theHesitation,
    String? tajweedErrors,
    String? comment,
    String? qiraat,
    bool ? notifiedToCallAgain,
  }) {
    return CallModel(
      callId: callId ?? this.callId,
      teacherUid: teacherUid ?? this.teacherUid,
      timestamp: timestamp ?? this.timestamp,
      studentUid: studentUid ?? this.studentUid,
      studentName: studentName ?? this.studentName,
      teacherName: teacherName ?? this.teacherName,
      studentPhoto: studentPhoto ?? this.studentPhoto,
      teacherPhoto: teacherPhoto ?? this.teacherPhoto,
      status: status ?? this.status,
      meetingLink: meetingLink ?? this.meetingLink,
      acceptedTime: acceptedTime ?? this.acceptedTime,
      endedTime: endedTime ?? this.endedTime,
      rating: rating ?? this.rating,
      record: record ?? this.record,
      fromSurah: fromSurah ?? this.fromSurah,
      toSurah: toSurah ?? this.toSurah,
      fromAyah: fromAyah ?? this.fromAyah,
      toAyah: toAyah ?? this.toAyah,
      numberOfFaces: numberOfFaces ?? this.numberOfFaces,
      wordErrors: wordErrors ?? this.wordErrors,
      theHesitation: theHesitation ?? this.theHesitation,
      tajweedErrors: tajweedErrors ?? this.tajweedErrors,
      comment: comment ?? this.comment,
      qiraat: qiraat ?? this.qiraat,
      notifiedToCallAgain: notifiedToCallAgain ?? this.notifiedToCallAgain,
    );
  }
}
