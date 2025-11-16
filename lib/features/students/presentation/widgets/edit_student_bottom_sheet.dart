import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/widgets/teacher_bottom_sheet_design.dart';
import 'delete_student_dialog.dart';

class EditStudentBottomSheet extends StatelessWidget {
  final UserModel userModel;

  const EditStudentBottomSheet({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return MyBottomSheetDesign(
      children: [
        BottomSheetItem(
          onTap: () {
            Navigator.pop(context);
            context
                .navigateTo(
              pageName: AppRoutes.editStudentScreen,
              arguments: [userModel],
            );
          },
          icon: Icons.edit,
          title: AppStrings.edit.tr(context),
        ),
        BottomSheetItem(
          onTap: () {
            Navigator.pop(context);
            showDialog(context: context, builder: (context)=>StudentDeleteConfigurationDialog(userModel: userModel,));

          },
          icon: Icons.delete,
          title: AppStrings.delete.tr(context),
          titleColor: AppColors.redColor,
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
