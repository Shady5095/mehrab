import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String details;
  final String role;
  final String specificUserName;
  final Timestamp timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.details,
    required this.role,
    required this.specificUserName,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']??'',
      title: json['title'],
      details: json['details'],
      role: json['role'],
      specificUserName: json['specificUserName'] ?? '',
      timestamp: json['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'role': role,
      'timestamp': timestamp,
    };
  }
}