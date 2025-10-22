
import '../../../../teachers/data/models/teachers_model.dart';

abstract class StudentCallState {}

final class TeacherCallInitial extends StudentCallState {}

final class SendCallToTeacherSuccess extends StudentCallState {}

final class SendCallToTeacherFailure extends StudentCallState {
  final String error;
  SendCallToTeacherFailure({required this.error});
}

final class CallEndedByUserState extends StudentCallState {}

final class CallEndedByTimeOut extends StudentCallState {}

final class TeacherInAnotherCall extends StudentCallState {}

final class CallAnsweredState extends StudentCallState {}

final class TeacherIsInMeetingButYouWillJoin extends StudentCallState {
  final String meetingId;
  TeacherIsInMeetingButYouWillJoin({required this.meetingId});
}

final class AnotherUserJoinedSuccessfully extends StudentCallState {}

final class AnotherUserLeft extends StudentCallState {}

final class CallFinished extends StudentCallState {
  final TeacherModel model;
  CallFinished({required this.model});
}

final class MaxDurationReached extends StudentCallState {}

final class AgoraConnectionError extends StudentCallState {
  final String error;
  AgoraConnectionError({required this.error});
}

final class MicrophoneNotAllowed extends StudentCallState {}

final class MicrophonePermanentlyDenied extends StudentCallState {}

final class MicrophoneAllowed extends StudentCallState {}
