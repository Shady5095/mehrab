import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../../core/utilities/resources/strings.dart';

class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/sessionExpiredPleaseLoginAgain.png", width: 60.sp),
          const SizedBox(height: 10),
          Text(
            AppStrings.sessionExpiredPleaseLoginAgain.tr(context),
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
