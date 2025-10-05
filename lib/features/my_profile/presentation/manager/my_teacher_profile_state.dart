
abstract class MyTeacherProfileState {}

final class MyTeacherProfileInitial extends MyTeacherProfileState {}

final class ProfileImagePickedState extends MyTeacherProfileState {}

final class UpdateProfileLoadingState extends MyTeacherProfileState {}

final class UpdateProfileSuccessState extends MyTeacherProfileState {}

final class UpdateProfileErrorState extends MyTeacherProfileState {
  final String errorMessage;

  UpdateProfileErrorState(this.errorMessage);
}
final class UpdatePasswordLoadingState extends MyTeacherProfileState {}

final class UpdatePasswordSuccessState extends MyTeacherProfileState {}

final class UpdatePasswordErrorState extends MyTeacherProfileState {
  final String errorMessage;

  UpdatePasswordErrorState(this.errorMessage);
}