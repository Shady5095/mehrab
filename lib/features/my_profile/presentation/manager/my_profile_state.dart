part of 'my_profile_cubit.dart';

@immutable
sealed class MyProfileState {}

final class MyProfileInitial extends MyProfileState {}

final class ProfileImagePickedState extends MyProfileState {}

final class UpdateProfileLoadingState extends MyProfileState {}

final class UpdateProfileSuccessState extends MyProfileState {}

final class UpdateProfileErrorState extends MyProfileState {
  final String errorMessage;

  UpdateProfileErrorState(this.errorMessage);
}
final class UpdatePasswordLoadingState extends MyProfileState {}

final class UpdatePasswordSuccessState extends MyProfileState {}

final class UpdatePasswordErrorState extends MyProfileState {
  final String errorMessage;

  UpdatePasswordErrorState(this.errorMessage);
}

final class DeleteAccountLoadingState extends MyProfileState {}

final class DeleteAccountSuccessState extends MyProfileState {}

final class DeleteAccountErrorState extends MyProfileState {
  final String errorMessage;

  DeleteAccountErrorState(this.errorMessage);
}

