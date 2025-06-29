import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../utilities/resources/colors.dart';

abstract class NavigationBarThemeCustom {
  static NavigationBarThemeData lightTheme =  NavigationBarThemeData(
    backgroundColor: Colors.white,


    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
      if (states.contains(WidgetState.selected)) {
        return  TextStyle(
          color: AppColors.accentColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        );
      }
      return TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.normal,
      );
    }),
    // for icon them make selecte acceng color and unselected grey color
    iconTheme:  WidgetStateProperty.resolveWith<IconThemeData>((states) {
      if (states.contains(WidgetState.selected)) {
      return const IconThemeData(
          color: AppColors.accentColor,
        );
      }
      return IconThemeData(
        color: AppColors.blackColor.withValues(
           alpha: 0.6,
        ),
      );
    })
  );

  static NavigationBarThemeData darkTheme =  NavigationBarThemeData(
    backgroundColor: AppColors.primaryDarkColor,
    elevation: 0,
    indicatorColor:AppColors.accentColor.withValues(
      alpha: 0.3,
    ),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        if (states.contains(WidgetState.selected)) {
          return  TextStyle(
            color: AppColors.accentColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          );
        }
        return TextStyle(
          fontSize: 10.sp,
          color: AppColors.greyColor,
          fontWeight: FontWeight.normal,
        );
      }),
      // for icon them make selecte acceng color and unselected grey color
      iconTheme:  WidgetStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: AppColors.accentColor,
          );
        }
        return const IconThemeData(
          color: AppColors.greyColor,
        );
      })
  );
}

