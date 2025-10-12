import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';

class InstructionsForStartSessionDialog extends StatelessWidget {
  const InstructionsForStartSessionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MyAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Center(
            child: Text(
                AppStrings.instructionsForStartSession.tr(context),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Center(child: Image(image: AssetImage('assets/images/instructionsForStartSession.jpg'),height: 200.sp,width: 200.sp,)),
          Text(
            AppStrings.firstInstructions.tr(context),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600
            ),
          ),
          Text(
            AppStrings.secondInstructions.tr(context),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600
            ),
          ),
          Text(
            AppStrings.thirdInstructions.tr(context),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppStrings.fourthInstructions.tr(context),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: "Cairo"
                  ),
                ),
                TextSpan(
                  text: ' (مهم جدا)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                      fontFamily: "Cairo"
                  ),
                ),
              ],
            ),
          ),
          Text(
            AppStrings.sixthInstructions.tr(context),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child:  Text(
            AppStrings.okayStartSession.tr(context),
            style: TextStyle(
              color: AppColors.myAppColor,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo"
            ),
          ),
        ),
      ],
    );
  }
}
