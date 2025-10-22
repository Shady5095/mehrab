import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/buttons_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../students/presentation/widgets/build_user_item_photo.dart';
import '../manager/student_call_cubit/student_call_cubit.dart';
import '../manager/student_call_cubit/student_call_state.dart';

class StudentCallScreenBody extends StatelessWidget {
  const StudentCallScreenBody({super.key});

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
                    AppStrings.microphonePermissionPermanentlyDenied.tr(context),
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
        }

        else if (state is MicrophoneNotAllowed) {
          context.pop();
          myToast(
            msg: AppStrings.microphonePermissionNotAllowed.tr(context),
            state: ToastStates.error,
            toastLength: Toast.LENGTH_LONG,
          );
        }
        else if (state is CallEndedByTimeOut) {
          context.pop();
          showDialog(
            context: context,
            builder:
                (BuildContext context) => AlertDialog(
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
            builder:
                (BuildContext context) => AlertDialog(
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
          showDialog(
            context: context,
            builder:
                (BuildContext context) => AlertDialog(
                  backgroundColor: Colors.white,
                  contentPadding: const EdgeInsets.all(30),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.onCallFinishedTitle.tr(context),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.asset(
                        "assets/images/sessionEnd.png",
                        width: 150.sp,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.onCallFinishedDescription.tr(context),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
          );
        }
      },
      builder: (context, state) {
        final cubit = StudentCallCubit.get(context);
        return SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(!cubit.isCallAnswered)
                      Lottie.asset(
                        "assets/json/ringing2.json",
                        width: 50.sp,
                        height: 50.sp,
                        fit: BoxFit.cover,
                      ),
                      if(cubit.isCallAnswered && !cubit.isAnotherUserJoined)
                        SizedBox(
                          width: 50.sp,
                          height: 50.sp,
                          child: Padding(
                            padding:  EdgeInsets.all(15.sp),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if(cubit.isAnotherUserJoined)
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
                            ]
                          ),
                        ),
                      SizedBox(width: 10.sp),
                      Text(
                       cubit.isAnotherUserJoined ? AppStrings.connected.tr(context) : AppStrings.ringing.tr(context),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.hR),
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      if(!cubit.isCallAnswered)
                      Lottie.asset(
                        "assets/json/ringing.json",
                        width: 250.sp,
                        height: 250.sp,
                        fit: BoxFit.cover,
                      ),
                      if(cubit.isCallAnswered)
                        SizedBox(
                          width: 250.sp,
                          height: 250.sp,
                        ),
                      BuildUserItemPhoto(
                        imageUrl: cubit.teacherModel.imageUrl,
                        radius: 70.sp,
                        imageColor: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.sp),
                  Text(
                    cubit.teacherModel.name,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  if(cubit.isCallAnswered)
                  StreamBuilder<String>(
                    stream: cubit.callTimerStream,
                    initialData: "00:00",
                    builder: (context, snapshot) {
                      final time = snapshot.data ?? "00:00";
                      return Text(
                        time,
                        style:  TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if(cubit.isCallAnswered)
                      Container(
                        decoration: BoxDecoration(
                          color:
                              cubit.isMicMuted
                                  ? Colors.white
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.all(15),
                          icon: Icon(
                            cubit.isMicMuted ? Icons.mic_off : Icons.mic,
                            color:
                                cubit.isMicMuted ? Colors.black : Colors.white,
                            size: 35.sp,
                          ),
                          onPressed: () {
                            cubit.toggleMicMute();
                          },
                        ),
                      ),
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
                            size: 35.sp,
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
                      if(cubit.isCallAnswered)
                      Container(
                        decoration: BoxDecoration(
                          color:
                              cubit.isSpeakerOn
                                  ? Colors.white
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.all(17),
                          icon: Icon(
                            Icons.volume_up,
                            color:
                                cubit.isSpeakerOn ? Colors.black : Colors.white,
                            size: 35.sp,
                          ),
                          onPressed: () {
                            cubit.switchSpeaker();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.hR),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
