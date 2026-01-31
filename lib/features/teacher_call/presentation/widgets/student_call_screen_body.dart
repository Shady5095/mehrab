import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/buttons_widget.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:custom_clippers/custom_clippers.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/services/app_review_service.dart';
import '../../../students/presentation/widgets/build_user_item_photo.dart';
import '../manager/student_call_cubit/student_call_cubit.dart';
import '../manager/student_call_cubit/student_call_state.dart';
import 'call_ended_dialog.dart';

class StudentCallScreenBody extends StatelessWidget {
  final TeacherModel teacherModel;
  const StudentCallScreenBody({super.key, required this.teacherModel});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentCallCubit, StudentCallState>(
      listener: (context, state) {
        if (state is MicrophonePermanentlyDenied) {
          context.pop();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(30),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.microphonePermissionTitle.tr(context),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.microphonePermissionPermanentlyDenied
                        .tr(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ButtonWidget(
                  onPressed: () {
                    openAppSettings();
                    context.pop();
                  },
                  height: 38,
                  label: AppStrings.openSettings.tr(context),
                )
              ],
            ),
          );
        } else if (state is MicrophoneNotAllowed) {
          context.pop();
          myToast(
            msg: AppStrings.microphonePermissionNotAllowed.tr(context),
            state: ToastStates.error,
            toastLength: Toast.LENGTH_LONG,
          );
        } else if (state is CameraPermissionPermanentlyDenied) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(30),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "إذن الكاميرا مطلوب",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "يجب السماح بإذن الكاميرا لاستخدام الفيديو. يرجى فتح الإعدادات والسماح بالوصول للكاميرا.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ButtonWidget(
                  onPressed: () {
                    openAppSettings();
                    context.pop();
                  },
                  height: 38,
                  label: AppStrings.openSettings.tr(context),
                )
              ],
            ),
          );
        } else if (state is CameraPermissionDenied) {
          myToast(
            msg: "يجب السماح بإذن الكاميرا لاستخدام الفيديو",
            state: ToastStates.warning,
            toastLength: Toast.LENGTH_SHORT,
          );
        } else if (state is CallEndedByTimeOut) {
          context.pop();
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              contentPadding: const EdgeInsets.all(30),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/teacher_no_answer.png",
                    height: 60.sp,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.callEnded.tr(context),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.callEndedDescription.tr(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else if (state is TeacherInAnotherCall) {
          context.pop();
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              contentPadding: const EdgeInsets.all(30),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/line_busy.png", height: 60.sp),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.lineBusy.tr(context),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.lineBusyDescription.tr(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else if (state is CallEndedByUserState) {
          context.pop();
        } else if (state is AgoraConnectionError) {
          myToast(
            msg: "${AppStrings.serverError.tr(context)} , ${state.error}",
            state: ToastStates.error,
            toastLength: Toast.LENGTH_LONG,
          );
        } else if (state is CallFinished ||
            state is MaxDurationReached ||
            state is AnotherUserLeft) {
          context.pop();
          // Show dialog after the current frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) => CallEndedDialog(
                teacherUid: teacherModel.uid,
              ),
            );
            AppReviewService.showReviewPromptIfNeeded();
          });
        }
      },
      builder: (context, state) {
        final cubit = StudentCallCubit.get(context);

        return Stack(
          children: [
            // Remote video (full screen when enabled)
            if (cubit.isRemoteVideoEnabled && cubit.remoteUid != null)
              Positioned.fill(
                child: cubit.callService.remoteVideoTrack != null
                    ? lk.VideoTrackRenderer(
                        cubit.callService.remoteVideoTrack!,
                        fit: lk.VideoViewFit.cover,
                      )
                    : Container(),
              ),

            // Default background with gradient
            if (!cubit.isRemoteVideoEnabled)
              Positioned.fill(
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Local video preview (small popup on top left)
            if (cubit.isVideoEnabled)
              Positioned(
                top: 20,
                left: 20,
                child: SafeArea(
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: cubit.callService.localVideoTrack != null
                        ? lk.VideoTrackRenderer(
                            cubit.callService.localVideoTrack!,
                            fit: lk.VideoViewFit.cover,
                            mirrorMode: lk.VideoViewMirrorMode.mirror,
                          )
                        : Container(),
                  ),
                ),
              ),

            // Main UI content
            Positioned.fill(
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Status indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if(cubit.isAnotherUserJoined&& !cubit.isVideoEnabled)
                              ...[InkWell(
                                onTap: () {
                                  context.navigateTo(pageName: AppRoutes.quranWebView);
                                },
                                child: ImageIcon(
                                  AssetImage('assets/images/book.png'),
                                  color: Colors.white,
                                  size: 30.sp,
                                ),
                              ),
                                Spacer(),],
                            if (!cubit.isCallAnswered)
                              Lottie.asset(
                                "assets/json/ringing2.json",
                                width: 50.sp,
                                height: 50.sp,
                                fit: BoxFit.cover,
                              ),
                            if (cubit.isCallAnswered &&
                                !cubit.isAnotherUserJoined)
                              SizedBox(
                                width: 50.sp,
                                height: 50.sp,
                                child: Padding(
                                  padding: EdgeInsets.all(15.sp),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            if (cubit.isAnotherUserJoined)
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: AppColors.coolGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.coolGreen,
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(width: 10.sp),
                            Text(
                              cubit.isAnotherUserJoined
                                  ? AppStrings.connected.tr(context)
                                  : AppStrings.ringing.tr(context),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if(cubit.isAnotherUserJoined && !cubit.isVideoEnabled)
                              ...[Spacer(),
                                Opacity(
                                  opacity: 0,
                                  child: ImageIcon(
                                    AssetImage('assets/images/book.png'),
                                    color: Colors.white,
                                    size: 30.sp,
                                  ),
                                ),
                                ],
                          ],
                        ),
                        if(!cubit.isRemoteVideoEnabled)
                          SizedBox(height: 15.hR)
                        else
                          SizedBox(height: 1.hR),

                        // Profile section (hide when remote video is on)
                        if (!cubit.isRemoteVideoEnabled) ...[
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              if (!cubit.isCallAnswered)
                                Lottie.asset(
                                  "assets/json/ringing.json",
                                  width: 250.sp,
                                  height: 250.sp,
                                  fit: BoxFit.cover,
                                ),
                              if (cubit.isCallAnswered)
                                SizedBox(
                                  width: 250.sp,
                                  height: 250.sp,
                                ),
                              BuildUserItemPhoto(
                                imageUrl: cubit.teacherModel.imageUrl,
                                radius: 70.sp,
                                imageColor: Colors.white,
                              ),
                              // Pre-comment bubble above teacher photo
                              if (cubit.currentPreComment != null)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 10,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: Duration(milliseconds: 400),
                                      curve: Curves.elasticOut,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Transform.translate(
                                            offset: Offset(0, (1 - value) * -20),
                                            child: Opacity(
                                              opacity: value.clamp(0.0, 1.0),
                                              child: child,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.90,
                                        ),
                                        child: ClipPath(
                                          clipper: LowerNipMessageClipper(
                                            MessageType.receive,
                                            bubbleRadius: 20,
                                            sizeOfNip: 2,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.white,
                                                  AppColors.white.withValues(alpha: 0.95),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.2),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.notifications_active_outlined,
                                                  color: AppColors.myAppColor,
                                                  size: 22.sp,
                                                ),
                                                SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    cubit.currentPreComment!,
                                                    maxLines: 5,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black87,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                            ],
                          ),
                          SizedBox(height: 10.sp),
                          Text(
                            cubit.teacherModel.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15),
                        ],

                        // Timer
                        if (cubit.isCallAnswered)
                          StreamBuilder<String>(
                            stream: cubit.callTimerStream,
                            initialData: "00:00",
                            builder: (context, snapshot) {
                              final time = snapshot.data ?? "00:00";
                              return Text(
                                time,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),

                        Spacer(),

                        // Control buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Video toggle button
                            if (cubit.isCallAnswered)
                              _buildControlButton(
                                icon: cubit.isVideoEnabled
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                                isActive: cubit.isVideoEnabled,
                                onPressed: () {
                                  cubit.toggleVideo();
                                },
                              ),
                            if (cubit.isCallAnswered) SizedBox(width: 2.5.wR),

                            // Speaker/Camera switch button
                            if (cubit.isCallAnswered)
                              _buildControlButton(
                                icon: cubit.isVideoEnabled
                                    ? CupertinoIcons.switch_camera
                                    : Icons.volume_up,
                                isActive: cubit.isVideoEnabled
                                    ? false
                                    : cubit.isSpeakerOn,
                                onPressed: () {
                                  if (cubit.isVideoEnabled) {
                                    cubit.switchCamera();
                                  } else {
                                    cubit.switchSpeaker();
                                  }
                                },
                              ),
                            if (cubit.isCallAnswered) SizedBox(width: 2.5.wR),
                            // Microphone button
                            if (cubit.isCallAnswered)
                              _buildControlButton(
                                icon: cubit.isMicMuted
                                    ? Icons.mic_off
                                    : Icons.mic,
                                isActive: cubit.isMicMuted,
                                onPressed: () {
                                  cubit.toggleMicMute();
                                },
                              ),

                            if (cubit.isCallAnswered) SizedBox(width: 2.5.wR),

                            // End call button
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.redColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.redColor,
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                padding: EdgeInsets.all(17),
                                icon: Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 7.wR,
                                ),
                                onPressed: () {
                                  if (cubit.isCallAnswered) {
                                    cubit.endCallAfterAnswer(isByUser: true);
                                  } else {
                                    cubit.endCallBeforeAnswer(isByUser: true);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.hR),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: IconButton(
        padding: EdgeInsets.all(15),
        icon: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 7.wR,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
