
import 'package:mehrab/features/authentication/data/google_sign_in_model.dart';

sealed class LoginStates {}

final class LoginScreenInitial extends LoginStates {}

class LoginWaitingState extends LoginStates {}

class LoginSuccessState extends LoginStates {}

class LoginErrorState extends LoginStates {
  final String error;

  LoginErrorState(this.error);
}

class GoogleSignInWaitingState extends LoginStates {}

class GoogleSignInSuccessState extends LoginStates {
  final GoogleSignInModel data;

  GoogleSignInSuccessState(this.data);
}

class GoogleSignInUsersAlreadyExists extends LoginStates {}

class GoogleSignInErrorState extends LoginStates {
  final String error;

  GoogleSignInErrorState(this.error);
}

class AppleSignInWaitingState extends LoginStates {}

class AppleSignInSuccessState extends LoginStates {
  final GoogleSignInModel data;

  AppleSignInSuccessState(this.data);
}

class AppleSignInUsersAlreadyExists extends LoginStates {}

class AppleSignInErrorState extends LoginStates {
  final String error;

  AppleSignInErrorState(this.error);
}

class ResetPasswordErrorState extends LoginStates {
  final String error;

  ResetPasswordErrorState(this.error);
}

class ResetPasswordSuccessState extends LoginStates {}

class BiometricsLoginLoadingState extends LoginStates {}

class BiometricsLoginSuccessState extends LoginStates {}

class BiometricsLoginErrorState extends LoginStates {
  final String error;

  BiometricsLoginErrorState(this.error);
}

class ThisEmailSignedWithEmailAndPasswordMethod extends LoginStates {}