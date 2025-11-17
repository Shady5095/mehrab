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
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:meta/meta.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../../core/utilities/functions/print_with_color.dart';
import '../../../../../core/utilities/functions/toast.dart';
import '../../../../../core/utilities/resources/strings.dart';

part 'add_teacher_state.dart';

class AddTeacherCubit extends Cubit<AddTeacherState> {
  AddTeacherCubit({
    this.teacherModel,
}) : super(AddTeacherInitial());

  static AddTeacherCubit get(context) => BlocProvider.of(context);

  File? imageFile;
  String? imageUrl;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  final auth = FirebaseAuth.instance;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TeacherModel? teacherModel ;

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
        if (size < (3.5 * 1048576)) {
          imageFile = File(croppedFile.path);
          emit(AddTeacherInitial());
        } else {
          emit(AddTeacherInitial());
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
    emit(AddTeacherInitial());
  }
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController specializationController = TextEditingController();
  TextEditingController foundationalTextsController = TextEditingController();
  TextEditingController categoriesController = TextEditingController();
  TextEditingController tracksController = TextEditingController();
  TextEditingController compositionsController = TextEditingController();
  TextEditingController curriculumController = TextEditingController();
  TextEditingController compatibilityController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController igazahController = TextEditingController();


  void generatePassword() {
    // Generate a random password only numbers with 6 digits
    passwordController.text = (100000 + (999999 - 100000) * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).toInt().toString();

  }
  bool isPasswordObscured = true;

  void togglePasswordVisibility() {
    isPasswordObscured = !isPasswordObscured;
    emit(AddTeacherInitial());
  }
  bool isMale = true;
  String? uid;

  Future<bool> isEmailAlreadyRegistered() async {
    try {
      final querySnapshot = await db
          .collection('users')
          .where('email', isEqualTo: emailController.text.trim())
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      printWithColor("Error checking email: $e");
      return false;
    }
  }
  TeacherModel get getUserModel => TeacherModel(
    uid: uid ?? '',
    name: nameController.text.trim(),
    email: emailController.text.trim(),
    phone: phoneController.text.trim(),
    password: passwordController.text.trim(),
    experience: experienceController.text.trim(),
    specialization: specializationController.text.trim().isEmpty ? null : specializationController.text.trim(),
    foundationalTexts: foundationalTextsController.text.trim().isEmpty ? null : foundationalTextsController.text.trim(),
    categories: categoriesController.text.trim().isEmpty ? null : categoriesController.text.trim(),
    tracks: tracksController.text.trim().isEmpty ? null : tracksController.text.trim(),
    compositions: compositionsController.text.trim().isEmpty ? null : compositionsController.text.trim(),
    curriculum: curriculumController.text.trim().isEmpty ? null : curriculumController.text.trim(),
    imageUrl: imageUrl,
    isMale: isMale,
    isOnline: teacherModel?.isOnline ?? false,
    userRole: 'teacher',
    lastActive: teacherModel?.lastActive ,
    joinedAt: teacherModel?.joinedAt?? Timestamp.now(),
    averageRating: teacherModel?.averageRating ?? 0.0,
    favoriteStudentsUid: teacherModel?.favoriteStudentsUid ?? [],
    compatibility: compatibilityController.text.trim().isEmpty ? null : compatibilityController.text.trim(),
    school: schoolController.text.trim().isEmpty ? null : schoolController.text.trim(),
    igazah: igazahController.text.trim().isEmpty ? null : igazahController.text.trim(),
    igazPdfUrl: igazPdfUrl,
    sessionsCount: teacherModel?.sessionsCount ?? 0,
    minutesCount: teacherModel?.minutesCount ?? 0,
    isBusy: teacherModel?.isBusy ?? false,
    rateCount: teacherModel?.rateCount ?? 0,
  );
  Future<void> signUpWithEmailAndPassword(BuildContext context) async {
    try {
      await auth
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      )
          .then((userCredential) => {uid = userCredential.user!.uid});
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      final errorMessage = switch (e.code) {
        'email-already-in-use' => AppStrings.emailUsedBefore.tr(context),
        'invalid-email' => AppStrings.thisEmailIsNotRegisteredBefore.tr(context),
        'user-not-found' => AppStrings.thisEmailIsNotRegisteredBefore.tr(context),
        'too-many-requests' => AppStrings.tooManyRequests.tr(context),
        'network-request-failed' => AppStrings.networkRequestFailed.tr(context),
        'operation-not-allowed' => 'Email/password account creation is not enabled in Firebase.',
        'invalid-credential' => AppStrings.thisEmailIsNotRegisteredBefore.tr(context),
        _ => 'An unexpected error occurred: ${e.message}',
      };
      emit(RegisterErrorState(errorMessage));
    }
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
          "Authorization": "Basic ${base64Encode(utf8.encode('private_ACQf3pOvrG3Z+lW/EzXeECiJbOs=:'))}",
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
        emit(RegisterErrorState("Image upload failed"));
      }
    } catch (e) {
      printWithColor("ImageKit upload error: $e");
      emit(RegisterErrorState("Image upload failed"));
    }
  }


  Future<void> addUserDataToFireStore() async {
    await db
        .collection('users')
        .doc(getUserModel.uid)
        .set(getUserModel.toJson())
        .then((value) {
      printWithColor("User data added successfully");
    })
        .catchError((error) {
      printWithColor("Error adding user data: $error");
      emit(RegisterErrorState(error.toString()));
    });
  }

  Future<void> registerUserWithEmailPassword(BuildContext context) async {
    if(!context.mounted) {
      return;
    }
    emit(RegisterLoadingState());
    if(await isEmailAlreadyRegistered()){
      if(!context.mounted) {
        return;
      }
      emit(RegisterErrorState(AppStrings.emailUsedBefore.tr(context)));
      return;
    }
    if(!context.mounted) {
      return;
    }
    await signUpWithEmailAndPassword(context);
    if(state is RegisterErrorState) {
      return;
    }
    await uploadImageToImageKit();
    await uploadIgazPdfToImageKit();
    await addUserDataToFireStore();
    emit(RegisterSuccessState());
  }
  void onTabAddTeacher(BuildContext context) {
    if (formKey.currentState!.validate()) {
      registerUserWithEmailPassword(context);
    }
  }

  void convertModelToEditing() {
    if(teacherModel == null) return;
    nameController.text = teacherModel!.name;
    emailController.text = teacherModel!.email;
    phoneController.text = teacherModel!.phone;
    passwordController.text = teacherModel!.password;
    experienceController.text = teacherModel!.experience;
    specializationController.text = teacherModel!.specialization ?? '';
    foundationalTextsController.text = teacherModel!.foundationalTexts ?? '';
    categoriesController.text = teacherModel!.categories ?? '';
    tracksController.text = teacherModel!.tracks ?? '';
    compositionsController.text = teacherModel!.compositions ?? '';
    curriculumController.text = teacherModel!.curriculum ?? '';
    imageUrl = teacherModel!.imageUrl;
    isMale = teacherModel!.isMale;
    uid = teacherModel!.uid;
    compatibilityController.text = teacherModel!.compatibility ?? '';
    schoolController.text = teacherModel!.school ?? '';
    igazahController.text = teacherModel!.igazah ?? '';
    igazPdfUrl = teacherModel!.igazPdfUrl;
  }

  Future<void> updateTeacher() async {
    if(teacherModel == null) return;
    if (formKey.currentState!.validate()) {
    emit(UpdateTeacherLoadingState());
    if(imageFile != null) {
      await uploadImageToImageKit();
    }
    if(igazPdfFile != null) {
      await uploadIgazPdfToImageKit();
    }
      await db
          .collection('users')
          .doc(teacherModel!.uid)
          .update(getUserModel.toJson())
          .then((value) {
        emit(UpdateTeacherSuccessState());
      })
          .catchError((error) {
        printWithColor("Error updating user data: $error");
        emit(UpdateTeacherErrorState(error.toString()));
      });
    }
  }

  File? igazPdfFile;
  String? igazPdfUrl;
  void pickIgazPdfFile() {
    FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'PDF'],
    )
        .then((value) async {
      if (value != null) {
        if (value.files.isNotEmpty) {
          final file = value.files.first;
          if (file.size < (5 * 1048576)) {
            igazPdfFile = File(file.path!);
            emit(AddTeacherInitial());
          } else {
            if (!formKey.currentContext!.mounted) return;
            myToast(
              toastLength: Toast.LENGTH_LONG,
              msg: ' ${AppStrings.lessFileSize.tr(formKey.currentContext!)} 5 MB',
              state: ToastStates.error,
            );
          }
        }
      } else {
        printWithColor('No files picked');
      }
    });
  }

  clearIgazPdf() {
    igazPdfFile = null;
    igazPdfUrl = null;
    emit(AddTeacherInitial());
  }
  Future<void> uploadIgazPdfToImageKit() async {
    if (igazPdfFile == null) return;

    try {
      final fileName = "إجازة المعلم ${nameController.text}.pdf";

      final bytes = await igazPdfFile!.readAsBytes();
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
          "folder": "/mehrab_igaz_pdf/",
          "useUniqueFileName": "true",
          "publicKey": "public_JGe/g1A7bPqoxvdcFyZOKPvd2sw=",
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        igazPdfUrl = result["url"];
        printWithColor("PDF uploaded successfully. URL: $igazPdfUrl");
      } else {
        printWithColor("PDFKit upload failed: ${response.body}");
        emit(RegisterErrorState("PDF upload failed"));
      }
    } catch (e) {
      printWithColor("PDFKit upload error: $e");
      emit(RegisterErrorState("PDF upload failed"));
    }
  }

  // dispose controllers
  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    experienceController.dispose();
    specializationController.dispose();
    foundationalTextsController.dispose();
    categoriesController.dispose();
    tracksController.dispose();
    compositionsController.dispose();
    curriculumController.dispose();
    compatibilityController.dispose();
    schoolController.dispose();
    igazahController.dispose();
    return super.close();
  }
}
