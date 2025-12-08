import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/buttons_widget.dart';
import 'package:mehrab/core/widgets/teacher_bottom_sheet_design.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:custom_clippers/custom_clippers.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../students/presentation/widgets/build_user_item_photo.dart';
import '../manager/teacher_call_cubit/teacher_call_cubit.dart';

class TeacherCallScreenBody extends StatelessWidget {
  const TeacherCallScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = TeacherCallCubit.get(context);
    return BlocConsumer<TeacherCallCubit, TeacherCallState>(
      listener: (context, state) {
        if (state is CameraPermissionPermanentlyDenied) {
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
          context.navigateTo(
            pageName: AppRoutes.rateSessionScreen,
            arguments: [cubit.callModel.copyWith(endedTime: Timestamp.now()), false],
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            // Remote video (full screen when enabled)
            if (cubit.isRemoteVideoEnabled && cubit.remoteUid != null)
              Positioned.fill(
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: cubit.callService.engine!,
                    canvas: VideoCanvas(uid: cubit.remoteUid),
                    connection: RtcConnection(
                      channelId: cubit.callModel.callId,
                    ),
                  ),
                ),
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
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: cubit.callService.engine!,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    ),
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
                            if (!cubit.isCallConnected)
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
                            if (cubit.isCallConnected)
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
                              cubit.isCallConnected
                                  ? AppStrings.connected.tr(context)
                                  : AppStrings.ringing.tr(context),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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
                              SizedBox(
                                width: 250.sp,
                                height: 250.sp,
                              ),
                              BuildUserItemPhoto(
                                imageUrl: cubit.callModel.studentPhoto,
                                radius: 70.sp,
                                imageColor: Colors.white,
                              ),
                              // Pre-comment bubble above student photo
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
                                            MessageType.send,
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
                                                  Icons.done_all,
                                                  color: AppColors.accentColor,
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
                            cubit.callModel.studentName,
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
                        if (cubit.isCallConnected)
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
                            if (cubit.isCallConnected)
                              _buildControlButton(
                                icon: cubit.isVideoEnabled
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                                isActive: cubit.isVideoEnabled,
                                onPressed: () {
                                  cubit.toggleVideo();
                                },
                              ),
                            if (cubit.isCallConnected) SizedBox(width: 2.5.wR),

                            // Speaker/Camera switch button
                            if (cubit.isCallConnected)
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
                            if (cubit.isCallConnected) SizedBox(width: 2.5.wR),
                            // Microphone button
                            if (cubit.isCallConnected)
                              _buildControlButton(
                                icon: cubit.isMicMuted
                                    ? Icons.mic_off
                                    : Icons.mic,
                                isActive: cubit.isMicMuted,
                                onPressed: () {
                                  cubit.toggleMicMute();
                                },
                              ),

                            if (cubit.isCallConnected) SizedBox(width: 2.5.wR),

                            // Pre-comments button
                            if (cubit.isCallConnected)
                              _buildControlButton(
                                icon: Icons.message,
                                isActive: false,
                                onPressed: () {
                                  _showPreCommentsMenu(context, cubit);
                                },
                              ),

                            if (cubit.isCallConnected) SizedBox(width: 2.5.wR),

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
                                padding: EdgeInsets.all(14),
                                icon: Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 6.7.wR,
                                ),
                                onPressed: () {
                                  cubit.endCall();
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
        padding: EdgeInsets.all(14),
        icon: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 6.7.wR,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showPreCommentsMenu(BuildContext context, TeacherCallCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FirstBottomSheetItem(),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'ارسال تعليق',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...cubit.preComments.map((comment) => GestureDetector(
                    onTap: () {
                      cubit.sendPreComment(comment);
                      context.pop();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.myAppColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.myAppColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        comment,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.myAppColor,
                        ),
                      ),
                    ),
                  )),
                  GestureDetector(
                    onTap: () {
                      context.pop();
                      _showCustomCommentDialog(context, cubit);
                    },
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: Radius.circular(25),
                      color: AppColors.myAppColor,
                      strokeWidth: 1.5,
                      dashPattern: [6, 3],
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          //color: AppColors.myAppColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 16.sp,
                              color: AppColors.myAppColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'اكتب تعليق اخر',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.myAppColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showCustomCommentDialog(BuildContext context, TeacherCallCubit cubit) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'اكتب تعليق',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'اكتب تعليقك هنا...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.myAppColor,
                width: 2,
              ),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final comment = commentController.text.trim();
              if (comment.isNotEmpty) {
                cubit.sendPreComment(comment);
                context.pop();
              }
            },
            child: Text(
              'إرسال',
              style: TextStyle(
                color: AppColors.myAppColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}