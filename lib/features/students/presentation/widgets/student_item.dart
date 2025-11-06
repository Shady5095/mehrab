import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/format_date_and_time.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';
import '../../../../core/config/routes/app_routes.dart';
import 'build_user_item_photo.dart';
import 'edit_student_bottom_sheet.dart';

class StudentItem extends StatelessWidget {
  final UserModel userModel;

  const StudentItem({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onLongPress: (){
          if(AppConstants.isAdmin){
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return EditStudentBottomSheet(userModel: userModel);
              },
            );
          }
        },
        onTap: () {
          context.navigateTo(
            pageName: AppRoutes.studentsProfileScreen,
            arguments: [userModel],
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
                tag: userModel.uid,
                child: BuildUserItemPhoto(
                  imageUrl: userModel.imageUrl,
                  radius: 29.sp,
                  imageColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userModel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${AppStrings.joinedDate.tr(context)} : ${formatDate(context, userModel.joinedAt)} : ${formatTime(context, userModel.joinedAt)}",
                      style: TextStyle(fontSize: 11.5.sp, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
