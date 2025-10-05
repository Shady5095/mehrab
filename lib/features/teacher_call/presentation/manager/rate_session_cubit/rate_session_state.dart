part of 'rate_session_cubit.dart';

@immutable
sealed class RateSessionState {}

final class RateSessionInitial extends RateSessionState {}

final class RateSessionUpdated extends RateSessionState {}

final class RateSessionLoading extends RateSessionState {}

final class RateSessionSuccess extends RateSessionState {}

final class RateSessionError extends RateSessionState {
  final String message;
  RateSessionError(this.message);
}
