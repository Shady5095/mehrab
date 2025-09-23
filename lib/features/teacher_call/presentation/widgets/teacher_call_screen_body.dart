import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';

import '../../../students/presentation/widgets/build_user_item_photo.dart';
import '../manager/teacher_call_cubit/teacher_call_cubit.dart';

class TeacherCallScreenBody extends StatelessWidget {
  const TeacherCallScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherCallCubit, TeacherCallState>(
      listener: (context, state) {
        if (state is CallEndedByTimeOut) {
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
        }
        else if (state is MeetingOpenedState) {
          context.pop();
        }
      },
      builder: (context, state) {
        final cubit = TeacherCallCubit.get(context);
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
                      Lottie.asset(
                        "assets/json/ringing2.json",
                        width: 50.sp,
                        height: 50.sp,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10.sp),
                      Text(
                        AppStrings.ringing.tr(context),
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
                      Lottie.asset(
                        "assets/json/ringing.json",
                        width: 250.sp,
                        height: 250.sp,
                        fit: BoxFit.cover,
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
                  SizedBox(height: 20),
                  if(state is CallAnsweredState)
                  Text(
                    AppStrings.callAccepted.tr(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  CircleAvatar(
                    radius: 30.sp,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                      onPressed: () {
                        cubit.endCall(isByUser: true);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
