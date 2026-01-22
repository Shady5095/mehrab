import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';

import '../../../../../core/utilities/functions/print_with_color.dart';
import '../../../../../core/utilities/functions/toast.dart';
import '../../../../../core/utilities/resources/strings.dart';

part 'edit_student_state.dart';

class EditStudentCubit extends Cubit<EditStudentState> {
  EditStudentCubit({
    required this.userModel,
}) : super(EditStudentInitial());

  static EditStudentCubit get(BuildContext context) => BlocProvider.of(context);

  final UserModel userModel ;

  File? imageFile;
  String? imageUrl;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
  TextEditingController phoneController = TextEditingController();
  String? selectedNationality;
  String? selectedEducationLevel;
  String countryCodeNumber = '+20';
  String countryCode = 'EG';

  String uid = '';
  bool isMale = true;

  void toggleGender() {
    isMale = !isMale;
    emit(ProfileImagePickedState());
  }

  void fillControllers() {
    nameController.text = userModel.name;
    emailController.text = userModel.email;
    phoneController.text = userModel.phoneNumber;
    selectedNationality = userModel.nationality;
    selectedEducationLevel = userModel.educationalLevel;
    uid = userModel.uid;
    isMale = userModel.isMale;
    countryCode = userModel.countryCode;
    countryCodeNumber = userModel.countryCodeNumber;
    passwordController.text = userModel.password;
    confirmPasswordController.text = userModel.password;
    imageUrl = userModel.imageUrl;
  }

  Future<void> uploadImageToImageKit() async {
    if (imageFile == null) return;

    try {
      final fileName = "${nameController.text}-$uid.jpg";

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
      }
    } catch (e) {
      printWithColor("ImageKit upload error: $e");
    }
  }

  Future<void> updateStudent()async {
    emit(EditStudentLoadingState());
    await uploadImageToImageKit();
    await db.collection("users").doc(uid).update({
      'name': nameController.text,
      'imageUrl': imageUrl,
      'phoneNumber': phoneController.text,
      'educationalLevel': selectedEducationLevel,
      'nationality': selectedNationality,
      'isMale': isMale,
      'countryCode': countryCode,
      'countryCodeNumber': countryCodeNumber,
    });
    emit(EditStudentSuccessState());
  }
}
