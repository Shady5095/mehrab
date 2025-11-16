import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';

import '../../../../core/utilities/resources/strings.dart';
import '../../../teachers/presentation/widgets/add_comment_dialog.dart';

class CallEndedDialog extends StatelessWidget {
  final String teacherUid;

  const CallEndedDialog({super.key, required this.teacherUid});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.onCallFinishedTitle.tr(context),
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          Image.asset("assets/images/sessionEnd.png", width: 150.sp),
          const SizedBox(height: 0),
          Text(
            AppStrings.onCallFinishedDescription.tr(context),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (CacheService.getData(key: "isThisTeacherRated-$teacherUid") !=
              true) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder:
                      (newContext) => AddCommentDialog(
                        teacherUid: teacherUid,
                        oldComment: null,
                        oldRating: null,
                      ),
                );
              },
              child: Text(
                AppStrings.rateTeacherNow.tr(context),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Cairo",
                  color: AppColors.myAppColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
