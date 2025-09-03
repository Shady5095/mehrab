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

final class TryAgainSubmitQuizSuccessState extends HomeState {}

final class TryAgainSubmitQuizErrorState extends HomeState {}
class ChangeSliderIndexState extends HomeState {
  final int index;
  ChangeSliderIndexState(this.index);
}

