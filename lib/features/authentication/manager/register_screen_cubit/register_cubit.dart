// 3. تعديل RegisterCubit (جعل googleSignInModel عامًا لدعم Apple، وتعيين signInMethod = "apple")
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/features/authentication/data/google_sign_in_model.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/services/account_storage_service.dart';
import '../../../../core/utilities/services/cache_service.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({this.socialSignInModel}) : super(RegisterInitial());  // تغيير الاسم إلى socialSignInModel للعامية
  final GoogleSignInModel? socialSignInModel;  // نفس الموديل، لكن عام

  static RegisterCubit instance(context) =>
      BlocProvider.of<RegisterCubit>(context);

  File? imageFile;
  String? imageUrl;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
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

  void onTabRegister(BuildContext context) {
    if (formKey.currentState!.validate()) {
      if(phoneController.text.trim().isEmpty && Platform.isAndroid){
        myToast(msg: "${AppStrings.mustHaveValue.tr(context)} ${AppStrings.phone.tr(context)}", state: ToastStates.error);
        return;
      }
      if(socialSignInModel != null){  // تغيير من googleSignInModel
        registerUserWithSocial(context);  // دالة عامة جديدة
      }else{
        registerUserWithEmailPassword(context);
      }

    }
  }

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

  String? uid;

  void fillSocialSignInData() {  // تغيير الاسم للعامية
    if (socialSignInModel != null) {  // تغيير من googleSignInModel
      nameController.text = socialSignInModel!.displayName ?? '';
      emailController.text = socialSignInModel!.email ?? '';
      phoneController.text = socialSignInModel!.phoneNumber ?? '';
      //imageUrl = socialSignInModel!.photoUrl;
      uid = socialSignInModel!.uid;
    }
    emit(ProfileImagePickedState());
  }

  UserModel get getUserModel {
    return UserModel(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phoneNumber: phoneController.text,
      uid: uid ?? '',
      isMale: isMale,
      userRole: "student",
      signInMethod: socialSignInModel != null ? socialSignInModel?.singInMethod??'' : "email",
      joinedAt: Timestamp.now(),
      nationality: selectedNationality ?? "unkonwn",
      educationalLevel: selectedEducationLevel ?? "unkonwn",
      imageUrl: imageUrl,
      countryCode: countryCode,
      countryCodeNumber: countryCodeNumber,
      favoriteIgaz: favoriteIgaz
    );
  }
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
    await addUserDataToFireStore();
    await cacheUid(uid??'');
    // SECURITY FIX: Removed password storage (CWE-256)
    // AccountStorage.saveAccount() has been deprecated for security reasons
    // Firebase Auth handles session management automatically
    emit(RegisterSuccessState());
  }

  // إضافة جديدة: دالة عامة لـ Social (Google أو Apple)
  Future<void> registerUserWithSocial(BuildContext context) async {
    emit(RegisterLoadingState());
    uid = socialSignInModel!.uid;  // تعيين UID من الموديل
    await uploadImageToImageKit();
    await addUserDataToFireStore();
    await cacheUid(uid??'');
    emit(RegisterSuccessState());
  }

  Future<void> cacheUid(String uid) async {
    await CacheService.setData(key: AppConstants.uid, value: uid).then((value) {
      if (value == true) {
        CacheService.uid = CacheService.getData(key: AppConstants.uid);
      }
    });
  }

  void autoSelectNationalityFromCache() {
    final cachedCode = CacheService.currentCountryCode;
    if (cachedCode != null) {
      final nationality = AppConstants.countryCodeToNationality[cachedCode.toUpperCase()];
      if (nationality != null && selectedNationality == null) { // Only if none chosen and mapping exists
        selectedNationality = nationality;
      }
    }
  }
  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    return super.close();
  }
}