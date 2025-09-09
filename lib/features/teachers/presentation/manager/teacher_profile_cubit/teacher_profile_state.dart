part of 'teacher_profile_cubit.dart';

@immutable
sealed class TeacherProfileState {}

final class TeacherProfileInitial extends TeacherProfileState {}

class ToggleTeacherFavLoadingState extends TeacherProfileState {}

class ToggleTeacherFavSuccessState extends TeacherProfileState {}

class ToggleTeacherFavErrorState extends TeacherProfileState {
  final String error;

  ToggleTeacherFavErrorState(this.error);
}
