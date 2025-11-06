import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/widgets/teacher_bottom_sheet_design.dart';

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
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
