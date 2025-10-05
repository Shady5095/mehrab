
abstract class AddNotificationState {}

final class AddNotificationInitial extends AddNotificationState {}

final class AddNotificationLoadingState extends AddNotificationState {}

final class AddNotificationSuccessState extends AddNotificationState {}

final class AddNotificationErrorState extends AddNotificationState {
  final String errorMessage;
  AddNotificationErrorState({required this.errorMessage});
}