part of 'teacher_call_cubit.dart';

@immutable
sealed class TeacherCallState {}

final class TeacherCallInitial extends TeacherCallState {}

final class SendCallToTeacherSuccess extends TeacherCallState {}

final class SendCallToTeacherFailure extends TeacherCallState {
  final String error;
  SendCallToTeacherFailure({required this.error});
}

final class CallEndedByUserState extends TeacherCallState {}

final class CallEndedByTimeOut extends TeacherCallState {}

final class TeacherInAnotherCall extends TeacherCallState {}

final class CallAnsweredState extends TeacherCallState {}

final class MeetingOpenedState extends TeacherCallState {}

final class TeacherIsInMeetingButYouWillJoin extends TeacherCallState {
  final String meetingId;
  TeacherIsInMeetingButYouWillJoin({required this.meetingId});
}

