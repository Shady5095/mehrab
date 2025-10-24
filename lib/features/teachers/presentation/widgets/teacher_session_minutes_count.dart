import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';


class TeacherSessionMinutesCount extends StatelessWidget {
  final TeacherModel model;
  const TeacherSessionMinutesCount({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(
                        Icons.access_time,
                        size: 19.sp,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.minutesCount.tr(context),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Countup(
                    begin: 0,
                    end:  model.minutesCount.toDouble(),
                    duration: const Duration(milliseconds: 1000),
                    separator: ',',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.myAppColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_collection_outlined,
                        size: 19.sp,
                        color:Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.sessionsCount.tr(context),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Countup(
                    begin: 0,
                    end: model.sessionsCount.toDouble(),
                    duration: const Duration(milliseconds: 1000),
                    separator: ',',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
