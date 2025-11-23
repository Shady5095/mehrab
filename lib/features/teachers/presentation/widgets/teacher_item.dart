import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/format_date_and_time.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/teachers/presentation/manager/teachers_cubit/teachers_cubit.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teachers_bottom_sheet_actions.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../data/models/teachers_model.dart';
import 'build_teacher_photo.dart';

class TeacherItem extends StatelessWidget {
  final TeacherModel teacher;

  final bool isLastItem;

  const TeacherItem({
    super.key,
    required this.teacher,
    required this.isLastItem,
  });

  @override
  Widget build(BuildContext context) {
    List<dynamic> args =
        ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    final bool isFav = args.isNotEmpty ? args[0] as bool : false;
    final bool isFromTeacherAcc = args.isNotEmpty ? args[1] as bool : false;
    final cubit = TeachersCubit.get(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLastItem ? 15.0 : 0,
        left: 20.0,
        right: 20.0,
      ),
      child: Card(
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            context.navigateTo(
              pageName: AppRoutes.teacherProfileScreen,
              arguments: [teacher],
            );
          },
          onLongPress: () {
            if (!AppConstants.isAdmin || isFav) return;
            showModalBottomSheet(
              context: context,
              builder:
                  (newContext) => TeachersBottomSheetActions(
                    teacherModel: teacher,
                    oldContext: context,
                    onFinish: (value) {
                      if (value != null) {
                        // Handle any actions after finishing
                      }
                    },
                  ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Hero(
                  tag: teacher.uid,
                  child: BuildTeacherPhoto(
                    imageUrl: teacher.imageUrl,
                    radius: 29.sp,
                    imageColor: Colors.white,
                    isOnline: teacher.isOnline,
                    isFromFav: isFav,
                    isBusy: teacher.isBusy,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                          teacher.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                          SizedBox(width: 2),
                          Icon(Icons.star, color: Colors.amber, size: 17.sp),
                          SizedBox(width: 2),
                          Text(
                            "(${teacher.rateCount})",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      if (!isFav)
                        Text(
                          teacher.isBusy
                              ? AppStrings.busy.tr(context)
                              : (teacher.isOnline
                                  ? AppStrings.availableNow.tr(context)
                                  : "${AppStrings.lastActive.tr(context)} : ${getDateKey(teacher.lastActive?.toDate(), DateTime.now(), DateTime.now().subtract(Duration(days: 1)), context)} ${formatTime(context, teacher.lastActive)}"),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                                teacher.isBusy
                                    ? AppColors.redColor
                                    : (teacher.isOnline
                                        ? AppColors.coolGreen
                                        : Colors.black54),
                          ),
                        ),
                    ],
                  ),
                ),
                if(!isFromTeacherAcc)
                IconButton(
                  onPressed: () async {
                    if (!teacher.isOnline) {
                      return;
                    }
                    if(teacher.isBusy) {
                      myToast(msg: AppStrings.teacherIsBusy.tr(context), state: ToastStates.normal,);
                      return;
                    }
                    context.navigateTo(
                      pageName: AppRoutes.studentCallScreen,
                      arguments: [teacher],
                    );
                  },
                  icon: Icon(
                    Icons.call,
                    size: 22.sp,
                    color:
                        teacher.isBusy
                            ? AppColors.redColor
                            : (teacher.isOnline
                                ? AppColors.coolGreen
                                : Colors.grey),
                  ),
                ),
                if(!isFromTeacherAcc)
                IconButton(
                  onPressed: () async {
                    await cubit.toggleTeacherFav(teacher.uid);
                    if (!context.mounted) return;
                    cubit.addStudentInTeacherCollection(teacher.uid);
                    cubit.addTeacherInStudentCollection(
                      teacher.copyWith(
                        favoriteStudentsUid:
                            isTeacherInMyFavorites
                                ? (teacher.favoriteStudentsUid..remove(myUid))
                                : (teacher.favoriteStudentsUid..add(myUid)),
                      ),
                    );
                  },
                  icon: Icon(
                    isTeacherInMyFavorites
                        ? Icons.favorite
                        : Icons.favorite_border_outlined,
                    size: 22.sp,
                    color:
                        isTeacherInMyFavorites
                            ? AppColors.redColor
                            : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get isTeacherInMyFavorites {
    if (teacher.favoriteStudentsUid.isNotEmpty) {
      return teacher.favoriteStudentsUid.contains(myUid);
    }
    return false; // Placeholder return value
  }
  String getDateKey(DateTime? callDate, DateTime now, DateTime yesterday, BuildContext context) {
    if(callDate == null) {
      return "--------";
    }
    if (isSameDay(callDate, now)) {
      return "${AppStrings.today.tr(context)} ${AppStrings.atTime.tr(context)}";
    } else if (isSameDay(callDate, yesterday)) {
      return "${AppStrings.yesterday.tr(context)} ${AppStrings.atTime.tr(context)}";
    } else {
      return "${formatDate(context, Timestamp.fromDate(callDate))} :";
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
