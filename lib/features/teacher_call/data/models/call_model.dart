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
      meetingLink: map['meetingLink']
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
