import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherCommentsModel {
  final String userUid;
  final String teacherUid;
  final String? comment;
  final num rating;
  final Timestamp timestamp;
  final String? userName;
  final String? userImage;
  final String? commentId;

  TeacherCommentsModel({
    required this.userUid,
    required this.teacherUid,
    this.comment,
    required this.rating,
    required this.timestamp,
    this.userName,
    this.userImage,
    this.commentId,
  });

  factory TeacherCommentsModel.fromJson(Map<String, dynamic> json) {
    return TeacherCommentsModel(
      userUid: json['userUid'] as String,
      teacherUid: json['teacherUid'] as String,
      comment: json['comment'] as String?,
      rating: json['rating'] as num,
      timestamp: json['timestamp'] as Timestamp,
      userName: json['userName'] as String?,
      userImage: json['userImage'] as String?,
      commentId: json['commentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userUid': userUid,
      'teacherUid': teacherUid,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp,
      'userName': userName,
      'userImage': userImage,
    };
  }
}