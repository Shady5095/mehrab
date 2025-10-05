import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/colors.dart';
import '../utilities/resources/strings.dart';
import '../utilities/resources/styles.dart';
import 'buttons_widget.dart';

class MyAlertDialog extends StatelessWidget {
  final Widget? content;
  final List<Widget>? actions;
  final bool? isFailed;
  final String? title;
  final VoidCallback? onTapYes;
  final Widget? icon;
  final EdgeInsetsGeometry? contentPadding;
  final bool? makeIosAndAndroidSameDialog;
  final double? width;

  const MyAlertDialog({
    super.key,
    this.content,
    this.actions,
    this.isFailed,
    this.title,
    this.onTapYes,
    this.icon,
    this.contentPadding,
    this.makeIosAndAndroidSameDialog,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || makeIosAndAndroidSameDialog == true) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsetsDirectional.only(end: 10, bottom: 20),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        icon:
            icon ??
            (isFailed != null
                ? CircleAvatar(
                  radius: 25.sp,
                  backgroundColor: isFailed! ? Colors.red : Colors.green,
                  child: Icon(
                    isFailed! ? Icons.close : Icons.check,
                    color: Colors.white,
                    size: 27.sp,
                  ),
                )
                : null),
        contentPadding:
            contentPadding ??
            EdgeInsets.only(
              bottom: 2.hR,
              top: 2.hR,
              right: 8.wR,
              left: 8.wR,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),

        //this right here
        content: SizedBox(
          width: width,
          child:
              content ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 1.hR),
                ],
              ),
        ),
        actions:
            actions ??
            [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ButtonWidget(
                  labelColor: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: AppStrings.no.tr(context),
                  color: AppColors.white,
                  width: 23.wR,
                  height: 3.5.hR,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ButtonWidget(
                  onPressed: onTapYes ?? () {},
                  label: AppStrings.yes.tr(context),
                  width: 23.wR,
                  height: 3.5.hR,
                  color: AppColors.myAppColor,
                ),
              ),
            ],
      );
    } else {
      return CupertinoAlertDialog(
        content:
            content ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 1.hR),
              ],
            ),
        actions:
            actions ??
            [
              CupertinoDialogAction(
                onPressed: onTapYes ?? () {},
                isDefaultAction: true,
                child: Text(
                  AppStrings.yes.tr(context),
                  style: AppStyle.textStyle14AccentColor,
                ),
              ),

              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppStrings.no.tr(context),
                  style: AppStyle.textStyleError,
                ),
              ),
            ],
      );
    }
  }
}
