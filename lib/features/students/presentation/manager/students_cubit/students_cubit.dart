import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:meta/meta.dart';

part 'students_state.dart';

class StudentsCubit extends Cubit<StudentsState> {
  StudentsCubit() : super(StudentsInitial());

  static StudentsCubit get(context) => BlocProvider.of(context);
  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void setSearchText(String query) {
    searchQuery = query.trim();
    emit(StudentsSearchUpdatedState());
  }

  void clearSearchText() {
    searchController.clear();
    searchQuery = '';
    emit(StudentsSearchUpdatedState());
  }

  Stream<QuerySnapshot> getStudentsStream({String? searchQuery}) {
    Query queryRef = db
        .collection('users')
        .where("userRole", isEqualTo: "student")
        .where("isMale", isEqualTo: currentUserModel?.isMale ?? true)
        .orderBy("joinedAt", descending: true);
    Query adminQueryRef = db
        .collection('users')
        .where("userRole", isEqualTo: "student")
        .orderBy("joinedAt", descending: true);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryRef = queryRef
          .where("name", isGreaterThanOrEqualTo: searchQuery)
          .where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff');
      adminQueryRef = adminQueryRef
          .where("name", isGreaterThanOrEqualTo: searchQuery)
          .where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    return AppConstants.isAdmin
        ? adminQueryRef.snapshots()
        : queryRef.snapshots();
  }

  Future<QuerySnapshot> getStudentsPage({
    String? searchQuery,
    DocumentSnapshot? lastDoc,
    int limit = 10,
  }) async {
    Query queryRef = db
        .collection('users')
        .where("userRole", isEqualTo: "student")
        .where("isMale", isEqualTo: currentUserModel?.isMale ?? true)
        .orderBy("joinedAt", descending: true)
        .limit(limit);
    
    Query adminQueryRef = db
        .collection('users')
        .where("userRole", isEqualTo: "student")
        .orderBy("joinedAt", descending: true)
        .limit(limit);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryRef = queryRef
          .where("name", isGreaterThanOrEqualTo: searchQuery)
          .where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff');
      adminQueryRef = adminQueryRef
          .where("name", isGreaterThanOrEqualTo: searchQuery)
          .where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    if (lastDoc != null) {
      queryRef = queryRef.startAfterDocument(lastDoc);
      adminQueryRef = adminQueryRef.startAfterDocument(lastDoc);
    }

    return AppConstants.isAdmin
        ? await adminQueryRef.get()
        : await queryRef.get();
  }
}
