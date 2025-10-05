part of 'prayer_time_cubit.dart';

@immutable
sealed class PrayerTimeState {}

final class PrayerTimeInitial extends PrayerTimeState {}

final class PrayerTimeLoading extends PrayerTimeState {}

final class PrayerTimeSuccess extends PrayerTimeState {}

final class PrayerTimeError extends PrayerTimeState {
  final String message;

  PrayerTimeError(this.message);
}
