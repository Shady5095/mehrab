import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';

import '../../../../core/utilities/functions/format_date_and_time.dart';
import '../../data/models/notification_model.dart';
import 'notifications_bottom_sheet_actions.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel model;

  const NotificationItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onLongPress: (){
          if(!AppConstants.isAdmin) return;
          showModalBottomSheet(
            context: context,
            builder: (newContext) => NotificationsBottomSheetActions(oldContext: context,notificationModel: model,),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image(
                    image: const AssetImage(AppAssets.notification),
                    width: 30.sp,
                    height: 30.sp,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      model.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Divider(

                ),
              ),
              Center(
                child: Text(
                  model.details,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  if(AppConstants.isAdmin)
                  Text(
                    "${AppStrings.to.tr(context)} : ${model.role == 'all' ? AppStrings.all.tr(context) : model.role == 'students' ? AppStrings.students.tr(context) : model.role == 'teachers' ? AppStrings.teachers.tr(context) : model.specificUserName}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Text(
                      "${formatDate(context, model.timestamp)} : ${formatTime(context, model.timestamp)}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
