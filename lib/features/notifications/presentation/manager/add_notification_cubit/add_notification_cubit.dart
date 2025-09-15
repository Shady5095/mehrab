import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';

import '../../../../../core/utilities/services/firebase_notification.dart';
import 'add_notification_state.dart';

class AddNotificationCubit extends Cubit<AddNotificationState> {
  AddNotificationCubit({required this.oneUserModel})
    : super(AddNotificationInitial());

  static AddNotificationCubit get(context) => BlocProvider.of(context);

  final UserModel? oneUserModel;

  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  bool isSendToStudents = true;
  bool isSendToTeachers = false;
  final db = FirebaseFirestore.instance;

  void changeSendToStudents(bool value) {
    isSendToStudents = value;
    emit(AddNotificationInitial());
  }

  void changeSendToTeachers(bool value) {
    isSendToTeachers = value;
    emit(AddNotificationInitial());
  }

  Future<void> addNotification() async {
    if (formKey.currentState!.validate()) {
      if (!isSendToStudents && !isSendToTeachers) {
        emit(AddNotificationErrorState(errorMessage: "برجاء اختيار المستلمين"));
        return;
      }
      emit(AddNotificationLoadingState());
      try {
        await db
            .collection('notifications')
            .add({
              'title': nameController.text,
              'details': detailsController.text,
              'role':
                  oneUserModel == null
                      ? (isSendToStudents && isSendToTeachers
                          ? 'all'
                          : isSendToStudents
                          ? 'students'
                          : 'teachers')
                      : oneUserModel!.uid,
              'timestamp': FieldValue.serverTimestamp(),
              if (oneUserModel != null) 'specificUserName': oneUserModel!.name,
            })
            .then((value) {
              value.update({'id': value.id});
            });
        emit(AddNotificationSuccessState());
        pushNotification();
      } catch (e) {
        emit(AddNotificationErrorState(errorMessage: e.toString()));
      }
    }
  }

  void pushNotification() {
    AppFirebaseNotification.pushNotification(
      title: nameController.text,
      body: detailsController.text,
      dataInNotification: {"type": "notification"},
      topic:
          oneUserModel == null
              ? (isSendToStudents && isSendToTeachers
                  ? 'all'
                  : isSendToStudents
                  ? 'student'
                  : 'teacher')
              : oneUserModel!.uid,
    );
  }
}
