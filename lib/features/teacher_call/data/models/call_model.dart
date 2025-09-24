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
  });

  factory CallModel.fromJson(Map<String, dynamic> map) {
    return CallModel(
      callId: map['callId'] ?? '',
      teacherUid: map['teacherUid'] ?? '',
      timestamp: map['timestamp'] ,
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      teacherName: map['teacherName'] ?? '',
      studentPhoto: map['studentPhoto'],
      teacherPhoto: map['teacherPhoto'],
      status: map['status'] ?? '',
      meetingLink: map['meetingLink'],
      acceptedTime: map['acceptedTime'],
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
}
