import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/services/firebase_notification.dart';
import 'package:mehrab/features/teachers/data/models/teacher_comment_model.dart';

import '../../../../../core/utilities/functions/print_with_color.dart';
import '../../../data/models/teachers_model.dart';

part 'teacher_profile_state.dart';

class TeacherProfileCubit extends Cubit<TeacherProfileState> {
  TeacherProfileCubit() : super(TeacherProfileInitial());

  static TeacherProfileCubit get(context) => BlocProvider.of(context);
  FirebaseFirestore db = FirebaseFirestore.instance;

  void toggleTeacherFav(String teacherUid) {
    if (state is ToggleTeacherFavLoadingState) {
      return;
    }
    emit(ToggleTeacherFavLoadingState());
    final userUid = currentUserModel?.uid;
    if (userUid == null || userUid.isEmpty) {
      return;
    }
    final teacherRef = db.collection("users").doc(teacherUid);
    db
        .runTransaction((transaction) async {
          final snapshot = await transaction.get(teacherRef);
          if (!snapshot.exists) {
            throw Exception("Teacher does not exist!");
          }

          List<dynamic> favStudents = (snapshot.data()?['favoriteStudentsUid'] as List<dynamic>?) ?? [];
          if (favStudents.contains(userUid)) {
            favStudents.remove(userUid);
          } else {
            favStudents.add(userUid);
            addInFavoritePushNotification(teacherUid);
          }
          transaction.update(teacherRef, {'favoriteStudentsUid': favStudents});
        })
        .then((value) {
          emit(ToggleTeacherFavSuccessState());
        })
        .catchError((error) {
          printWithColor(error);
          emit(ToggleTeacherFavErrorState(error.toString()));
        });
  }

  void addStudentInTeacherCollection(String teacherUid) {
    final userUid = currentUserModel?.uid;
    if (userUid == null || userUid.isEmpty) {
      return;
    }
    final teacherRef = db
        .collection("users")
        .doc(teacherUid)
        .collection("favoriteStudents")
        .doc(userUid);
    teacherRef
        .get()
        .then((value) {
      if (value.exists) {
        teacherRef.delete();
      } else {
        teacherRef.set(currentUserModel!.toJson());
      }
    })
        .catchError((error) {
      printWithColor(error);
    });
  }

  void addTeacherInStudentCollection(TeacherModel model) {
    final userUid = currentUserModel?.uid;
    if (userUid == null || userUid.isEmpty) {
      return;
    }
    final studentRef = db
        .collection("users")
        .doc(userUid)
        .collection("favoriteTeachers")
        .doc(model.uid);
    studentRef
        .get()
        .then((value) {
      if (value.exists) {
        studentRef.delete();
      } else {
        studentRef.set(model.toJson());
      }
    })
        .catchError((error) {
      printWithColor(error);
    });
  }

  PageController pageController = PageController();
  int currentIndex = 0;

  void changeIndex(int index) {
    currentIndex = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    emit(ChangeTeacherProfileIndexState());
  }

  void rateTeacher(String teacherUid, num newRating, {String? comment}) async {
    if (state is RateTeacherLoadingState) {
      return;
    }
    emit(RateTeacherLoadingState());
    final userUid = currentUserModel?.uid;
    if (userUid == null || userUid.isEmpty) {
      emit(RateTeacherErrorState("User UID is invalid"));
      return;
    }

    try {
      // Find existing comment by the user
      final commentsSnapshot =
          await db
              .collection("users")
              .doc(teacherUid)
              .collection("comments")
              .where('userUid', isEqualTo: userUid)
              .limit(1)
              .get();

      if (commentsSnapshot.docs.isNotEmpty) {
        // Update existing comment
        final commentDoc = commentsSnapshot.docs.first;
        final updatedComment = TeacherCommentsModel(
          userUid: userUid,
          teacherUid: teacherUid,
          comment: comment ?? commentDoc.data()['comment'],
          rating: newRating,
          timestamp: Timestamp.now(),
          userName: currentUserModel?.name,
          userImage: currentUserModel?.imageUrl,
          commentId: commentDoc.id,
        );
        await commentDoc.reference.update(updatedComment.toJson());
      } else {
        // Add new comment with commentId
        final commentRef =
            db.collection("users").doc(teacherUid).collection("comments").doc();
        final newComment = TeacherCommentsModel(
          userUid: userUid,
          teacherUid: teacherUid,
          comment: comment,
          rating: newRating,
          timestamp: Timestamp.now(),
          userName: currentUserModel?.name,
          userImage: currentUserModel?.imageUrl,
          commentId: commentRef.id,
        );
        await commentRef.set(newComment.toJson());
      }

      // Recalculate average rating after comment is set/updated
      final allCommentsSnapshot =
          await db
              .collection("users")
              .doc(teacherUid)
              .collection("comments")
              .get();
      if (allCommentsSnapshot.docs.isNotEmpty) {
        final totalRating = allCommentsSnapshot.docs
            .map((doc) => (doc.data()['rating'] as num))
            .reduce((a, b) => a + b);
        final averageRating = totalRating / allCommentsSnapshot.docs.length;
        // Update teacher document with new average rating
        await db.collection("users").doc(teacherUid).update({
          'averageRating': averageRating,
        });
      }
      rateTeacherPushNotification(teacherUid, newRating.toInt(),
          comment: comment);
      emit(RateTeacherSuccessState());
    } catch (error) {
      printWithColor(error);
      emit(RateTeacherErrorState(error.toString()));
    }
  }

  void rateTeacherPushNotification(
    String teacherUid,
    int rating, {
    String? comment,
  }) {
    printWithColor(comment);
    AppFirebaseNotification.pushNotification(
      title:
          "تقييم جديد من ${currentUserModel?.name ?? ''} (${rating.toString()} نجوم)",
      body: comment ?? '',
      dataInNotification: {"type": "studentRate"},
      topic: teacherUid,
    );
  }
  void addInFavoritePushNotification(String teacherUid) {
    AppFirebaseNotification.pushNotification(
      title: "لديك طالب جديد ضمك الي المفضلة",
      body:  'الطالب ${currentUserModel?.name ?? ''} قام باضافتك الي قائمة المفضلة الخاصه به',
      dataInNotification: {"type": "studentFavorite"},
      topic: teacherUid,
    );
  }
}
