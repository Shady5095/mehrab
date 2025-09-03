import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/services/cache_service.dart';
import '../../data/google_sign_in_model.dart';
import 'login_screen_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signInWithGoogle() async {
    emit(GoogleSignInWaitingState());
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
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

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    secondFocusNode.dispose();
    return super.close();
  }
}
