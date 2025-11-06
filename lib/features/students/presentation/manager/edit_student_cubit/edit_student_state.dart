part of 'edit_student_cubit.dart';

@immutable
sealed class EditStudentState {}

final class EditStudentInitial extends EditStudentState {}

final class ProfileImagePickedState extends EditStudentState {}

final class EditStudentLoadingState extends EditStudentState {}

final class EditStudentSuccessState extends EditStudentState {}

final class EditStudentErrorState extends EditStudentState {
  final String error;

  EditStudentErrorState(this.error);
}

