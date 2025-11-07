import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
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
import 'package:meta/meta.dart';

import '../../../../core/utilities/functions/print_with_color.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../authentication/data/user_model.dart';

part 'my_profile_state.dart';

class MyProfileCubit extends Cubit<MyProfileState> {
  MyProfileCubit({
    required this.userModel,
}) : super(MyProfileInitial());

  UserModel userModel ;
  static MyProfileCubit instance(context) => BlocProvider.of(context);

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
  String? selectedNationality;
  String? selectedEducationLevel;
  String countryCodeNumber = '+20';
  String countryCode = 'EG';

  bool isMale = true;
  String? favoriteIgaz;
  final List<String> qiraatList = [
    'قراءة نافع المدني',
    'قراءة ابن كثير',
    'قراءة ابن عامر',
    'قراءة أبي عمرو',
    'قراءة عاصم',
    'قراءة حمزة',
    'قراءة الكسائي',
    'قراءة أبي جعفر',
    'قراءة خلف البزار',
    'قراءة يعقوب',
  ];
  void toggleGender() {
    isMale = !isMale;
    emit(ProfileImagePickedState());
  }

  void fillAllFieldsFromModel() {
    imageUrl = userModel.imageUrl;
    nameController.text = userModel.name;
    emailController.text = userModel.email;
    phoneController.text = userModel.phoneNumber;
    selectedEducationLevel = userModel.educationalLevel;
    selectedNationality = userModel.nationality;
    isMale = userModel.isMale ;
    countryCode = userModel.countryCode;
    countryCodeNumber = userModel.countryCodeNumber;
    favoriteIgaz = userModel.favoriteIgaz;
  }

  UserModel get getUserModel {
    return UserModel(
      name: nameController.text,
      email: userModel.email,
      password: userModel.password,
      phoneNumber: phoneController.text,
      uid: userModel.uid,
      isMale: isMale,
      userRole: userModel.userRole,
      signInMethod: userModel.signInMethod,
      joinedAt: userModel.joinedAt,
      nationality: selectedNationality ?? "unkonwn",
      educationalLevel: selectedEducationLevel ?? "unkonwn",
      imageUrl: imageUrl,
      countryCode: countryCode,
      countryCodeNumber: countryCodeNumber,
      favoriteIgaz: favoriteIgaz
    );
  }

  Future<void> uploadImageToImageKit() async {
    if (imageFile == null) return;

    try {
      final fileName = "${nameController.text}-${userModel.uid}.jpg";

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
      email: userModel.email,
      password: oldPasswordController.text,
    );
    // ReAuthenticate with old password
    await FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential)
        .then((value) {
      db.collection('users').doc(userModel.uid).update({
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

  Future<void> deleteMyAccount() async {
    emit(DeleteAccountLoadingState());
    try {
      if (userModel.signInMethod == 'email') {
        AuthCredential credential = EmailAuthProvider.credential(
          email: userModel.email,
          password: userModel.password,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        await FirebaseAuth.instance.currentUser?.delete();
      }
      await db.collection('users').doc(userModel.uid).delete();
      emit(DeleteAccountSuccessState());
    } catch (error) {
      emit(DeleteAccountErrorState(error.toString()));
      printWithColor("Error deleting account: $error");
    }
  }
}
