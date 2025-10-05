part of 'add_teacher_cubit.dart';

@immutable
sealed class AddTeacherState {}

final class AddTeacherInitial extends AddTeacherState {}

final class RegisterLoadingState extends AddTeacherState {}

final class RegisterSuccessState extends AddTeacherState {}

final class RegisterErrorState extends AddTeacherState {
  final String errorMessage;

  RegisterErrorState(this.errorMessage);
}

final class UpdateTeacherLoadingState extends AddTeacherState {}

final class UpdateTeacherSuccessState extends AddTeacherState {}

final class UpdateTeacherErrorState extends AddTeacherState {
  final String errorMessage;

  UpdateTeacherErrorState(this.errorMessage);
}