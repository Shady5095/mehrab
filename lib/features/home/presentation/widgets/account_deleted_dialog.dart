import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../../core/utilities/resources/strings.dart';

class AccountDeletedDialog extends StatelessWidget {
  const AccountDeletedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/userDeleted.png", width: 60.sp),
          const SizedBox(height: 10),
          Text(
            AppStrings.yourAccountWasDeleted.tr(context),
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.yourAccountWasDeletedDescription.tr(context),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
