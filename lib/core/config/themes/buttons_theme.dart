import 'package:flutter/material.dart';

import '../../utilities/resources/colors.dart';
import '../../utilities/resources/dimens.dart';
import '../../utilities/resources/styles.dart';

abstract class ButtonsTheme {
  static ElevatedButtonThemeData elevatedButtonLightTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.myAppColor,
          textStyle: AppStyle.textStyle14,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
        ),
      );
  static OutlinedButtonThemeData outlinedButtonLightTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.myAppColor),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
}
