part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class ChangeNavBarState extends HomeState {
  final int? currentIndex;
  ChangeNavBarState({this.currentIndex});
}

final class GetUserDataSuccessState extends HomeState {}

final class GetUserDataWaitingState extends HomeState {}

final class GetUserDataErrorState extends HomeState {
  final String mess;

  GetUserDataErrorState(this.mess);
}

class ChangeSliderIndexState extends HomeState {
  final int index;
  ChangeSliderIndexState(this.index);
}
class ToggleTeacherFavLoadingState extends HomeState {}

class ToggleTeacherFavSuccessState extends HomeState {}

class NotificationsRefresh extends HomeState {}

class ChangeTeacherAvailabilityState extends HomeState {}

class ErrorWhileCreateMeeting extends HomeState {
  final String error;

  ErrorWhileCreateMeeting(this.error);
}
class AccountWasDeleted extends HomeState {}