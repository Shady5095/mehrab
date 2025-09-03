import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? imageUrl;
  final String countryCode;
  final String countryCodeNumber;
  final String phoneNumber;
  final String educationalLevel;
  final String nationality;
  final String secureKey;
  final String userRole;
  final String signInMethod;
  final DateTime createdAt;
  final bool isMale;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.imageUrl,
    required this.phoneNumber,
    required this.countryCode,
    required this.countryCodeNumber,
    required this.educationalLevel,
    required this.nationality,
    required this.secureKey,
    required this.userRole,
    required this.signInMethod,
    required this.createdAt,
    required this.isMale,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      educationalLevel: json['educationalLevel'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      secureKey: json['secureKey'] as String? ?? '',
      userRole: json['userRole'] as String? ?? '',
      signInMethod: json['signInMethod'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isMale: json['isMale'] as bool,
      countryCode: json['countryCode'] as String? ?? '',
      countryCodeNumber: json['countryCodeNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'educationalLevel': educationalLevel,
      'nationality': nationality,
      'secureKey': secureKey,
      'userRole': userRole,
      'signInMethod': signInMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'isMale': isMale,
      'countryCode': countryCode,
      'countryCodeNumber': countryCodeNumber,
    };
  }
}