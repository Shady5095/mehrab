import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> toggleTeacherFav(String teacherUid) async {
    if(state is ToggleTeacherFavLoadingState){
      return;
    }
    // in db i have users collection and each teacher has a list of fav students that favorited him
    // i need to add the current user uid to that list if not exist and remove it if exist
    // // if the list is null i need to create it
    emit(ToggleTeacherFavLoadingState());
    final userUid = currentUserModel?.uid;
    if(userUid == null || userUid.isEmpty){
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
  void addStudentInTeacherCollection(String teacherUid){
    final userUid = currentUserModel?.uid;
    if(userUid == null || userUid.isEmpty){
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
  void addTeacherInStudentCollection(TeacherModel model){
    final userUid = currentUserModel?.uid;
    if(userUid == null || userUid.isEmpty){
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
}
