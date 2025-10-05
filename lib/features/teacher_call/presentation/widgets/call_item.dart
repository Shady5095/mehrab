import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import 'package:mehrab/features/teacher_call/presentation/manager/calls_cubit/calls_cubit.dart';

import '../../../../app/main_app_cubit/main_app_cubit.dart';
import '../../../../core/utilities/functions/format_date_and_time.dart';
import '../../../students/presentation/widgets/build_user_item_photo.dart';

class CallItem extends StatelessWidget {
  final CallModel model;

  const CallItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final cubit = CallsCubit.get(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Column(
        children: [
          Row(
            children: [
              BuildUserItemPhoto(
                imageUrl: model.studentPhoto,
                radius: 25.sp,
                imageColor: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(model.status.tr(context),style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    getCallIcon(model.status),
                    color: getCallIconColor(model.status),
                    size: 20.sp,
                  ),
                  SizedBox(height: 5),
                  Text(
                    formatTime(context, model.timestamp),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
          if(model.status == 'answered')
          Row(
            children: [
              if(model.meetingLink != null)
              Expanded(
                child: TextButton(
                  onPressed: () {
                    cubit.openMeet(model.meetingLink!).catchError((error) {
                      myToast(msg: error.toString(), state: error);
                    });
                  },
                  child: Text(
                    AppStrings.reJoin.tr(context),
                    style: TextStyle(
                        color: AppColors.myAppColor.withValues(alpha: 0.8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: MainAppCubit.instance(context).setFontFamily()
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    cubit.endCall(model.callId,model.studentUid,model.teacherName).catchError((error) {
                      myToast(msg: error.toString(), state: error);
                    });
                  },
                  child: Text(
                    AppStrings.endCall.tr(context),
                    style: TextStyle(
                      color: AppColors.redColor.withValues(alpha: 0.8),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: MainAppCubit.instance(context).setFontFamily()
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  IconData getCallIcon(String status) {
    switch (status) {
      case 'answered':
        return Icons.phone_callback_outlined;
        case 'ended':
        return Icons.call;
      case 'missed':
        return Icons.phone_missed_rounded;
      case 'declined':
        return Icons.phone_disabled;
      default:
        return Icons.call;
    }
  }
  Color getCallIconColor(String status) {
    switch (status) {
      case 'answered':
        return Colors.blue;
      case 'ended':
        return AppColors.coolGreen;
      case 'missed':
        return Colors.red;
      case 'declined':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
