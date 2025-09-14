import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/format_date_and_time.dart';
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

  const TeacherItem({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    final bool isFav = args.isNotEmpty ? args[0] as bool : false;
    return Card(
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
                      style:  TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 17.sp),
                        SizedBox(width: 3),
                        Text(
                          teacher.averageRating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    if(!isFav)
                    Text(
                        teacher.isOnline ? AppStrings.availableNow.tr(context) :  "${AppStrings.lastActive.tr(context)} : ${formatDate(context, teacher.lastActive)}  : ${formatTime(context, teacher.lastActive)}",
                      style: TextStyle(fontSize: 12.sp, color:teacher.isOnline ?AppColors.coolGreen : Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {

                 await TeachersCubit.get(context).toggleTeacherFav(teacher.uid);
                 if(!context.mounted) return;
                  TeachersCubit.get(context).addStudentInTeacherCollection(teacher.uid);
                  TeachersCubit.get(context).addTeacherInStudentCollection(teacher.copyWith(
                    favoriteStudentsUid: isTeacherInMyFavorites
                        ? (teacher.favoriteStudentsUid..remove(myUid))
                        : (teacher.favoriteStudentsUid..add(myUid)),
                  ));
                },
                icon: Icon(isTeacherInMyFavorites ? Icons.favorite : Icons.favorite_border_outlined, size: 22.sp,color: isTeacherInMyFavorites ? AppColors.redColor : Colors.black,),
              ),
            ],
          ),
        ),
      ),
    );
  }
  bool get isTeacherInMyFavorites {
    if(teacher.favoriteStudentsUid.isNotEmpty) {
      return teacher.favoriteStudentsUid.contains(myUid);
    }
    return false; // Placeholder return value
  }
}
