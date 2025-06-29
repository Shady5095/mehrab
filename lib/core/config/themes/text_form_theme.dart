import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../utilities/resources/colors.dart';
import '../../utilities/resources/dimens.dart';
import '../../utilities/resources/styles.dart';

abstract class TextFormTheme {
  static InputDecorationTheme inputDecorationLightTheme = InputDecorationTheme(
    labelStyle: TextStyle(color: AppColors.blueGrey, fontSize: 11.sp),
    hintStyle: TextStyle(color: AppColors.blueGrey, fontSize: 11.sp),
    prefixIconColor: AppColors.blackColor,
    suffixIconColor: AppColors.blackColor,
    errorMaxLines: 3,

    enabledBorder: TextFormTheme.setOutlineInputBorder(
      color: AppColors.greyBlue.withValues(alpha: 0.6),
    ),
    focusedBorder: TextFormTheme.setOutlineInputBorder(
      color: AppColors.blackColor,
      width: 1.5,
    ),
    errorBorder: TextFormTheme.setOutlineInputBorder(color: AppColors.redColor),
    focusedErrorBorder: TextFormTheme.setOutlineInputBorder(
      color: AppColors.redColor,
      width: 2,
    ),
    errorStyle: AppStyle.formErrorStyle,
    disabledBorder: TextFormTheme.setOutlineInputBorder(
      color: AppColors.greyBlue.withValues(alpha: 0.6),
    ),
  );
  static InputDecorationTheme inputDecorationDarkTheme = InputDecorationTheme(
    labelStyle: TextStyle(color: AppColors.blueGrey, fontSize: 11.sp),
    hintStyle: TextStyle(color: AppColors.blueGrey, fontSize: 11.sp),
    prefixIconColor: AppColors.white,
    suffixIconColor: AppColors.white,
    errorMaxLines: 2,
    enabledBorder: TextFormTheme.setOutlineInputBorder(
      color: AppColors.greyBlue.withValues(alpha: 0.7),
    ),
    focusedBorder: TextFormTheme.setOutlineInputBorder(color: AppColors.white),
    errorBorder: TextFormTheme.setOutlineInputBorder(color: AppColors.redColor),
    focusedErrorBorder: TextFormTheme.setOutlineInputBorder(
      color: AppColors.redColor,
      width: 1.5,
    ),
    errorStyle: AppStyle.formErrorStyle,
    disabledBorder: TextFormTheme.setOutlineInputBorder(
      color: AppColors.greyBlue.withValues(alpha: 0.6),
    ),
  );

  static OutlineInputBorder setOutlineInputBorder({
    required Color color,
    double width = 1,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
    borderSide: BorderSide(color: color, width: width),
  );
}
