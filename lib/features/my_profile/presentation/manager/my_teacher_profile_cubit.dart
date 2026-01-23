import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';

import '../../../../core/utilities/functions/print_with_color.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/strings.dart';
import 'my_teacher_profile_state.dart';


class MyTeacherProfileCubit extends Cubit<MyTeacherProfileState> {
  MyTeacherProfileCubit({
    required this.teacherModel,
  }) : super(MyTeacherProfileInitial());

  TeacherModel teacherModel ;
  static MyTeacherProfileCubit instance(BuildContext context) => BlocProvider.of(context);

  File? imageFile;
  String? imageUrl;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  final auth = FirebaseAuth.instance;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  Future<void> pickProfileImage(BuildContext context) async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            toolbarTitle: 'Edit Photo',
            backgroundColor: Colors.black,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Edit Photo', aspectRatioLockEnabled: true),
        ],
      );
      if (croppedFile != null) {
        final imagePass = await croppedFile.readAsBytes();
        final size = imagePass.length;
        printWithColor(size);
        if (size < (3.5 * 1048576)) {
          imageFile = File(croppedFile.path);
          emit(ProfileImagePickedState());
        } else {
          emit(ProfileImagePickedState());
          if (!context.mounted) return;
          myToast(
            toastLength: Toast.LENGTH_LONG,
            msg: ' ${AppStrings.lessFileSize.tr(context)} 3.5 MB',
            state: ToastStates.error,
          );
        }
      }
    }
  }

  void removeCurrentImage() {
    imageFile = null;
    imageUrl = null;
    emit(ProfileImagePickedState());
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isMale = true;

  void toggleGender() {
    isMale = !isMale;
    emit(ProfileImagePickedState());
  }

  void fillAllFieldsFromModel() {
    imageUrl = teacherModel.imageUrl;
    nameController.text = teacherModel.name;
    emailController.text = teacherModel.email;
    phoneController.text = teacherModel.phone;
    isMale = teacherModel.isMale ;
  }

  TeacherModel get getUserModel {
    return TeacherModel(
      name: nameController.text,
      email: teacherModel.email,
      password: teacherModel.password,
      phone: phoneController.text,
      uid: teacherModel.uid,
      isMale: isMale,
      imageUrl: imageUrl ?? teacherModel.imageUrl,
      compatibility: teacherModel.compatibility,
      compositions: teacherModel.compositions,
      curriculum: teacherModel.curriculum,
      foundationalTexts: teacherModel.foundationalTexts,
      categories: teacherModel.categories,
      tracks: teacherModel.tracks,
      experience: teacherModel.experience,
      userRole: teacherModel.userRole,
      averageRating: teacherModel.averageRating,
      favoriteStudentsUid: teacherModel.favoriteStudentsUid,
      joinedAt: teacherModel.joinedAt,
      lastActive: teacherModel.lastActive,
      specialization: teacherModel.specialization,
      igazah: teacherModel.igazah,
      school: teacherModel.school,
      isOnline: teacherModel.isOnline,
      igazPdfUrl: teacherModel.igazPdfUrl,
      sessionsCount: teacherModel.sessionsCount,
      minutesCount: teacherModel.minutesCount,
      isBusy: teacherModel.isBusy,
      rateCount: teacherModel.rateCount,
      nationality: teacherModel.nationality,
      deviceModel: teacherModel.deviceModel,
    );
  }

  Future<void> uploadImageToImageKit() async {
    if (imageFile == null) return;

    try {
      final fileName = "${nameController.text}-${teacherModel.uid}.jpg";

      final bytes = await imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final uri = Uri.parse("https://upload.imagekit.io/api/v1/files/upload");

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Basic ${base64Encode(utf8.encode('private_ACQf3pOvrG3Z+lW/EzXeECiJbOs=:'))}", // or use Public API with unsigned uploads
        },
        body: {
          "file": base64Image,
          "fileName": fileName,
          "folder": "/mehrab_profile_images/",
          "useUniqueFileName": "true",
          "publicKey": "public_JGe/g1A7bPqoxvdcFyZOKPvd2sw=",
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        imageUrl = result["url"];
        printWithColor("Image uploaded successfully. URL: $imageUrl");
      } else {
        printWithColor("ImageKit upload failed: ${response.body}");
        emit(UpdateProfileErrorState("Image upload failed"));
      }
    } catch (e) {
      printWithColor("ImageKit upload error: $e");
      emit(UpdateProfileErrorState("Image upload failed"));
    }
  }

  Future<void> updateDataToFireStore() async {
    await db
        .collection('users')
        .doc(getUserModel.uid)
        .update(getUserModel.toJson())
        .then((value) {
      printWithColor("User data updated successfully");
    })
        .catchError((error) {
      printWithColor("Error adding user data: $error");
      emit(UpdateProfileErrorState(error.toString()));
    });
  }

  Future<void> onClickUpdateProfile() async {
    if (formKey.currentState!.validate()) {
      emit(UpdateProfileLoadingState());
      await uploadImageToImageKit();
      await updateDataToFireStore();
      if(state is UpdateProfileErrorState){
        return;
      }
      emit(UpdateProfileSuccessState());
    }
  }
  bool isOldPasswordObscured = true;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  void togglePasswordVisibility() {
    isPasswordObscured = !isPasswordObscured;
    emit(ProfileImagePickedState());
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured = !isConfirmPasswordObscured;
    emit(ProfileImagePickedState());
  }
  void toggleOldPasswordVisibility() {
    isOldPasswordObscured = !isOldPasswordObscured;
    emit(ProfileImagePickedState());
  }

  Future<void> changePassword(BuildContext context) async {
    emit(UpdatePasswordLoadingState());
    AuthCredential credential = EmailAuthProvider.credential(
      email: teacherModel.email,
      password: oldPasswordController.text,
    );
    // ReAuthenticate with old password
    await FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential)
        .then((value) {
      db.collection('users').doc(teacherModel.uid).update({
        'password' : passwordController.text,
      });
      // updatePassword
      FirebaseAuth.instance.currentUser
          ?.updatePassword(passwordController.text)
          .then((value) {
        emit(UpdatePasswordSuccessState());
      }).catchError((error) {
        emit(UpdatePasswordErrorState(error.toString()));
      });
    }).catchError((error) {
      if(!context.mounted) return;
      emit(UpdatePasswordErrorState(AppStrings.currentPasswordIncorrect.tr(context)));
    });
  }
}
