part of 'teachers_cubit.dart';

@immutable
sealed class TeachersState {}

final class TeachersInitial extends TeachersState {}

class ToggleTeacherFavLoadingState extends TeachersState {}

class ToggleTeacherFavSuccessState extends TeachersState {}

class ToggleTeacherFavErrorState extends TeachersState {
  final String error;

  ToggleTeacherFavErrorState(this.error);
}