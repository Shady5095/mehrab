import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/app/app_locale/app_locale.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/services/account_storage_service.dart';
import '../../../../core/utilities/services/biometric_service.dart';
import '../../../../core/utilities/services/cache_service.dart';
import '../../../../core/widgets/account_selection_bottom_sheet.dart';
import '../../data/google_sign_in_model.dart';
import 'login_screen_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';  // إضافة جديدة
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;  // للـ OAuthProvider

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginScreenInitial());

  static LoginCubit instance(BuildContext context) => BlocProvider.of(context);
  final formKey = GlobalKey<FormState>();
  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final secondFocusNode = FocusNode();

  void buttonFunction(BuildContext context) {
    if (formKey.currentState?.validate() == true) {
      signInWithEmailAndPassword(context);

    }
  }

  bool _googleSignInInitialized = false;

  Future<void> _initGoogleSignIn() async {
    if (!_googleSignInInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleSignInInitialized = true;
    }
  }

  Future<void> signInWithGoogle() async {
    emit(GoogleSignInWaitingState());
    try {
      await _initGoogleSignIn();
      await GoogleSignIn.instance.signOut();

      final GoogleSignInAccount googleUser;
      try {
        googleUser = await GoogleSignIn.instance.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          emit(GoogleSignInErrorState('Google Sign-In cancelled'));
          return;
        }
        rethrow;
      }

      if(await isEmailAlreadyRegistered(googleUser.email)){
        await GoogleSignIn.instance.signOut();
        emit(ThisEmailSignedWithEmailAndPasswordMethod());
        return;
      }

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (await checkUidExistsBefore(userCredential.user?.uid ?? '')) {
        await cacheUid(userCredential.user?.uid ?? '');
        emit(GoogleSignInUsersAlreadyExists());
      } else {
        emit(
          GoogleSignInSuccessState(
            GoogleSignInModel(
              email: userCredential.user?.email,
              displayName: userCredential.user?.displayName,
              photoUrl: userCredential.user?.photoURL,
              uid: userCredential.user?.uid,
              phoneNumber: userCredential.user?.phoneNumber,
              singInMethod: "google",
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage =
        'The account already exists with a different credential.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credential. Please try again.';
      } else {
        errorMessage = 'Firebase Auth Error: ${e.message}';
      }
      emit(GoogleSignInErrorState(errorMessage));
    } catch (e) {
      emit(GoogleSignInErrorState('An unexpected error occurred: $e'));
    }
  }

  Future<void> signInWithApple() async {
    emit(GoogleSignInWaitingState());
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'your-services-id.com.yourapp',
          redirectUri: Uri.parse('https://yourapp.com/callbacks/sign_in_with_apple_cb'),
        ),
      );
      final firebaseCredential = firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(firebaseCredential);
      final socialModel = GoogleSignInModel(
        email: userCredential.user?.email ?? appleCredential.email,
        displayName: userCredential.user?.displayName ??
            ((appleCredential.givenName == null && appleCredential.familyName == null)
                ? null
                : '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim()),
        photoUrl: userCredential.user?.photoURL,
        uid: userCredential.user?.uid,
        phoneNumber: userCredential.user?.phoneNumber,
        singInMethod: "apple",
      );

      if (await checkUidExistsBefore(userCredential.user?.uid ?? '')) {
        await cacheUid(userCredential.user?.uid ?? '');
        emit(GoogleSignInUsersAlreadyExists());
      } else {
        emit(GoogleSignInSuccessState(socialModel));
      }
    } on FirebaseAuthException catch (e) {
      emit(GoogleSignInErrorState('Firebase Auth Error: ${e.message}'));
    } catch (e) {
      emit(GoogleSignInErrorState('An unexpected error occurred: $e'));
    }
  }


  Future<bool> checkUidExistsBefore(String uid) async {
    bool uidExists = false;
    await db
        .collection("users")
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        printWithColor("User with this UID already exists.");
        uidExists = true; // UID exists
      } else {
        printWithColor("No user found with this UID.");
        uidExists = false; // UID does not exist
      }
    })
        .catchError((error) {
      printWithColor("Error checking UID: $error");
      uidExists = false; // Assume UID does not exist on error
    });
    return uidExists;
  }

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    emit(LoginWaitingState());
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await cacheUid(user.user?.uid ?? '');
      AccountStorage.saveAccount(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      emit(LoginSuccessState());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if(!context.mounted){
        return;
      }
      switch (e.code) {
      // Possible FirebaseAuthException error codes for signInWithEmailAndPassword
        case 'invalid-email':
          errorMessage = AppStrings.invalidEmail.tr(context);
          break;
        case 'user-disabled':
          errorMessage = AppStrings.userDisabled.tr(context);
          break;
        case 'user-not-found':
          errorMessage = AppStrings.userNotFound.tr(context);
          break;
        case 'wrong-password':
          errorMessage = AppStrings.wrongPassword.tr(context);
          break;
        case 'invalid-credential':
          errorMessage = AppStrings.invalidCredential.tr(context);
          break;
        case 'too-many-requests':
          errorMessage = AppStrings.tooManyRequests.tr(context);
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password login is not enabled in Firebase.';
          break;
        case 'account-exists-with-different-credential':
          errorMessage =
          'An account already exists with a different credential.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        case 'credential-already-in-use':
          errorMessage =
          'The credential is already associated with another user account.';
          break;
        case 'email-already-in-use':
          errorMessage =
          'The email address is already in use by another account.';
          break;
        default:
          errorMessage = 'An unexpected error occurred: ${e.message}';
      }
      emit(LoginErrorState(errorMessage));
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      myToast(
        msg: AppStrings.pleaseEnterYourEmailToResetYourPassword.tr(context),
        state: ToastStates.error,
      );
      return;
    }

    emit(LoginWaitingState());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(ResetPasswordSuccessState());
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      final errorMessage = switch (e.code) {
        'invalid-email' => AppStrings.thisEmailIsNotRegisteredBefore.tr(context),
        'user-not-found' => AppStrings.thisEmailIsNotRegisteredBefore.tr(context),
        'too-many-requests' => AppStrings.tooManyRequests.tr(context),
        'network-request-failed' => AppStrings.networkRequestFailed.tr(context),
        'operation-not-allowed' => 'Password reset is not enabled in Firebase.',
        'invalid-credential' => AppStrings.thisEmailIsNotRegisteredBefore.tr(context),
        _ => 'An unexpected error occurred: ${e.message}',
      };

      emit(ResetPasswordErrorState(errorMessage));
    } catch (e) {
      emit(ResetPasswordErrorState("Unexpected error: ${e.toString()}"));
    }
  }

  Future<void> cacheUid(String uid) async {
    await CacheService.setData(key: AppConstants.uid, value: uid).then((value) {
      if (value == true) {
        CacheService.uid = CacheService.getData(key: AppConstants.uid);
      }
    });
  }
  Future<void> loginWithBiometrics(BuildContext context) async {
    if (!kDebugMode) {
      final authenticated = await BiometricService.authenticate(isArabic(context)); // أو false
      if (!authenticated) return;
    }

    if (!context.mounted) return;

    Map<String, String> accounts = await AccountStorage.getAccounts();

    if (accounts.isEmpty) {
      myToast(msg: "مفيش حسابات محفوظة", state: ToastStates.error);
      return;
    }

    if (!context.mounted) return;

    final selectedEmail = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AccountSelectionBottomSheet(
          accounts: accounts,
          onSelect: (email) => Navigator.pop(context, email),
          onDelete: (email) {
            // لو عايز تعرض Toast أو تعمل أي رد فعل إضافي بعد الحذف
          },
        );
      },
    );

    if (selectedEmail != null) {
      final password = accounts[selectedEmail]!;
      try {
        emit(BiometricsLoginLoadingState());
        final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: selectedEmail,
          password: password,
        );
        await cacheUid(user.user?.uid ?? '');
        emit(LoginSuccessState());
      } catch (e) {
        emit(LoginErrorState("فشل تسجيل الدخول: $e"));
      }
    }
  }
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      final querySnapshot = await db
          .collection('users')
          .where('email', isEqualTo: email).where("password", isNotEqualTo: '')
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      printWithColor("Error checking email: $e");
      return false;
    }
  }


  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    secondFocusNode.dispose();
    return super.close();
  }
}