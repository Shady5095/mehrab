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
          backgroundColor: AppColors.azure,
          textStyle: AppStyle.textStyle14,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
        ),
      );
  static OutlinedButtonThemeData outlinedButtonLightTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.azure),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
}
