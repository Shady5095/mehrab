import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../resources/colors.dart';
import '../resources/strings.dart';
import '../resources/styles.dart';

void showSuccessDialog({
  required BuildContext context,
  required String text,
  required SuccessStates state,
  String? routeName,
  String? image,
}) {
  if (routeName != null) {
    Navigator.of(context).popUntil((route) => route.settings.name == routeName);
  } else {
    context.pop(result: true);
  }

  showDialog(
    context: context,
    builder:
        (BuildContext context) => AlertDialog(
          contentPadding: const EdgeInsets.all(30),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor:
                    image != null ? Colors.transparent : AppColors.coolGreen,
                backgroundImage: image != null ? AssetImage(image) : null,
                radius: 30.sp,
                child: Icon(Icons.done, color: AppColors.white, size: 40.sp),
              ),
              const SizedBox(height: 20),
              Text(
                '${text.tr(context)} ${successDialogText(state).tr(context)}',
                style: AppStyle.textStyle13,
              ),
            ],
          ),
        ),
  );
}

enum SuccessStates { add, edit, delete }

String successDialogText(SuccessStates state) {
  switch (state) {
    case SuccessStates.add:
      return AppStrings.addSuccessfully;
    case SuccessStates.edit:
      return AppStrings.editedSuccessfully;
    case SuccessStates.delete:
      return AppStrings.deletedSuccessfully;
  }
}
