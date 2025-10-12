
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
   String uid;
   String name;
   String email;
   String phone;
   String password;
   String userRole;
   String experience;
   String? specialization;
   String? foundationalTexts;
   String? categories;
   String? tracks;
   String? compositions;
   String? curriculum;
   String? compatibility;
   String? school;
   String? igazah;
   String? imageUrl;
   bool isMale;
   bool isOnline ;
   Timestamp? lastActive;
   Timestamp? joinedAt;
   double averageRating;
   List<String> favoriteStudentsUid ;
   String? igazPdfUrl ;

  TeacherModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.userRole,
    required this.experience,
    required this.specialization,
    required this.foundationalTexts,
    required this.categories,
    required this.tracks,
    required this.compositions,
    required this.curriculum,
    required this.imageUrl,
    required this.isMale,
    required this.isOnline,
    required this.lastActive,
    required this.joinedAt,
    required this.averageRating,
    required this.favoriteStudentsUid,
    required this.compatibility,
    required this.school,
    required this.igazah,
    this.igazPdfUrl,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userRole: json['userRole'] ?? 'teacher',
      password: json['password'] ?? '',
      experience: json['experience'] ?? '',
      specialization: json['specialization'],
      foundationalTexts: json['foundationalTexts'],
      categories: json['categories'],
      tracks: json['tracks'],
      compositions: json['compositions'],
      curriculum: json['curriculum'],
      imageUrl: json['imageUrl'],
      isMale: json['isMale'] ?? true,
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'] ,
      joinedAt: json['joinedAt'] ,
      averageRating: (json['averageRating'] != null) ? (json['averageRating'] as num).toDouble() : 0.0,
      favoriteStudentsUid: List<String>.from(json['favoriteStudentsUid'] ?? []),
      compatibility: json['compatibility'],
      school: json['school'],
      igazah: json['igazah'],
      igazPdfUrl: json['igazPdfUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'experience': experience,
      'specialization': specialization,
      'foundationalTexts': foundationalTexts,
      'categories': categories,
      'tracks': tracks,
      'compositions': compositions,
      'curriculum': curriculum,
      'imageUrl': imageUrl,
      'isMale': isMale,
      'isOnline': isOnline,
      'userRole': userRole,
      'lastActive': lastActive,
      'joinedAt': joinedAt,
      'averageRating': averageRating,
      'favoriteStudentsUid': favoriteStudentsUid,
      'compatibility': compatibility,
      'school': school,
      'igazah': igazah,
      'igazPdfUrl': igazPdfUrl,
    };
  }

  // create deep copy method
  TeacherModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? userRole,
    String? experience,
    String? specialization,
    String? foundationalTexts,
    String? categories,
    String? tracks,
    String? compositions,
    String? curriculum,
    String? compatibility,
    String? school,
    String? igazah,
    String? imageUrl,
    bool? isMale,
    bool? isOnline,
    Timestamp? lastActive,
    Timestamp? joinedAt,
    double? averageRating,
    List<String>? favoriteStudentsUid,
    String? igazPdfUrl,
  }) {
    return TeacherModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      userRole: userRole ?? this.userRole,
      experience: experience ?? this.experience,
      specialization: specialization ?? this.specialization,
      foundationalTexts: foundationalTexts ?? this.foundationalTexts,
      categories: categories ?? this.categories,
      tracks: tracks ?? this.tracks,
      compositions: compositions ?? this.compositions,
      curriculum: curriculum ?? this.curriculum,
      imageUrl: imageUrl ?? this.imageUrl,
      isMale: isMale ?? this.isMale,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      joinedAt: joinedAt ?? this.joinedAt,
      averageRating: averageRating ?? this.averageRating,
      favoriteStudentsUid: favoriteStudentsUid ?? List.from(this.favoriteStudentsUid),
      compatibility: compatibility ?? this.compatibility,
      school: school ?? this.school,
      igazah: igazah ?? this.igazah,
      igazPdfUrl:  igazPdfUrl ?? this.igazPdfUrl,
    );
  }
}