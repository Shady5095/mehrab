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

final class TeacherIsInMeetingButYouWillJoin extends TeacherCallState {
  final String meetingId;
  TeacherIsInMeetingButYouWillJoin({required this.meetingId});
}

final class AnotherUserJoinedSuccessfully extends TeacherCallState {}

final class AnotherUserLeft extends TeacherCallState {}

final class CallFinished extends TeacherCallState {}

final class MaxDurationReached extends TeacherCallState {}

final class AgoraConnectionError extends TeacherCallState {
  final String error;
  AgoraConnectionError({required this.error});
}
final class CameraPermissionDenied extends TeacherCallState {}

final class CameraPermissionPermanentlyDenied extends TeacherCallState {}

final class VideoStateChanged extends TeacherCallState {}

final class RemoteVideoStateChanged extends TeacherCallState {}

final class PreCommentReceived extends TeacherCallState {
  final String comment;
  PreCommentReceived({required this.comment});
}

final class PreCommentCleared extends TeacherCallState {}