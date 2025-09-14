import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:meta/meta.dart';

import '../../../../../core/utilities/functions/print_with_color.dart';
import '../../../data/models/teachers_model.dart';

part 'teachers_state.dart';

class TeachersCubit extends Cubit<TeachersState> {
  TeachersCubit() : super(TeachersInitial());

  static TeachersCubit get(context) => BlocProvider.of(context);
  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<void> toggleTeacherFav(String teacherUid) async {
    if (state is ToggleTeacherFavLoadingState) {
      return;
    }
    emit(ToggleTeacherFavLoadingState());
    final userUid = currentUserModel?.uid;
    if (userUid == null || userUid.isEmpty) {
      return;
    }
    final teacherRef = db.collection("users").doc(teacherUid);
    await db.runTransaction((transaction) async {
      final snapshot = await transaction.get(teacherRef);
      if (!snapshot.exists) {
        throw Exception("Teacher does not exist!");
      }

      List<dynamic> favStudents = snapshot.get('favoriteStudentsUid') ?? [];
      if (favStudents.contains(userUid)) {
        favStudents.remove(userUid);
      } else {
        favStudents.add(userUid);
      }
      transaction.update(teacherRef, {'favoriteStudentsUid': favStudents});
    }).then((value) {
      emit(ToggleTeacherFavSuccessState());
    }).catchError((error) {
      printWithColor(error);
      emit(ToggleTeacherFavErrorState(error.toString()));
    });
  }

  void addStudentInTeacherCollection(String teacherUid) {
    final userUid = currentUserModel?.uid;
    if (userUid == null || userUid.isEmpty) {
      return;
    }
    final teacherRef = db.collection("users").doc(teacherUid).collection("favoriteStudents").doc(userUid);
    teacherRef.get().then((value) {
      if (value.exists) {
        teacherRef.delete();
      } else {
        teacherRef.set(currentUserModel!.toJson());
      }
    }).catchError((error) {
      printWithColor(error);
    });
  }

  void addTeacherInStudentCollection(TeacherModel model) {
    final userUid = currentUserModel?.uid;
    if (userUid == null || userUid.isEmpty) {
      return;
    }
    final studentRef = db.collection("users").doc(userUid).collection("favoriteTeachers").doc(model.uid);
    studentRef.get().then((value) {
      if (value.exists) {
        studentRef.delete();
      } else {
        studentRef.set(model.toJson());
      }
    }).catchError((error) {
      printWithColor(error);
    });
  }

  void setSearchText(String query) {
    searchQuery = query.trim();
    emit(TeachersSearchUpdatedState());
  }

  void clearSearchText() {
    searchController.clear();
    searchQuery = '';
    emit(TeachersSearchUpdatedState());
  }

  Stream<QuerySnapshot> getTeachersStream({required bool isFav, String? searchQuery}) {
    Query queryRef = isFav
        ? db.collection('users').doc(myUid).collection('favoriteTeachers').where("userRole", isEqualTo: "teacher")
        : AppConstants.isAdmin ? db.collection('users').where("userRole", isEqualTo: "teacher").orderBy("isOnline", descending: true).orderBy("name", descending: false) : db.collection('users').where("userRole", isEqualTo: "teacher").where("isMale",isEqualTo: currentUserModel?.isMale??true).orderBy("isOnline", descending: true).orderBy("name", descending: false);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryRef = queryRef.where("name", isGreaterThanOrEqualTo: searchQuery).where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    return queryRef.snapshots();
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}