part of 'calls_cubit.dart';

@immutable
sealed class CallsState {}

final class CallsInitial extends CallsState {}

final class EndCallSuccess extends CallsState {}

final class EndCallError extends CallsState {
  final String error;
  EndCallError(this.error);
}
