import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../app/main_app_cubit/main_app_cubit.dart';
import '../../utilities/resources/colors.dart';
import '../../utilities/resources/styles.dart';
import 'bottom_navigation_bar_theme.dart';
import 'buttons_theme.dart';
import 'text_form_theme.dart';

class AppLightThemes {
  static ThemeData appLightTheme(BuildContext context) => ThemeData(
    primaryColor: AppColors.white,
    secondaryHeaderColor: Colors.black,
    shadowColor: const Color(0xffE1E2E4),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
    ),
    listTileTheme: const ListTileThemeData(textColor: AppColors.blackColor),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: AppStyle.textStyle14,
        foregroundColor: AppColors.blackColor,
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.white,
      labelStyle: TextStyle(
        color: AppColors.blackColor,

      ),
      selectedColor: AppColors.myAppColor,
      secondarySelectedColor: AppColors.myAppColor,
      disabledColor: AppColors.greyColor,
      selectedShadowColor: AppColors.myAppColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.myAppColor,
      foregroundColor: AppColors.white,
    ),
    navigationBarTheme: NavigationBarThemeCustom.lightTheme,
    elevatedButtonTheme: ButtonsTheme.elevatedButtonLightTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.myAppColor,
    ).copyWith(secondary: AppColors.myAppColor),
    checkboxTheme: ThemeData.light().checkboxTheme.copyWith(
      fillColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.myAppColor;
        }
        return Colors.transparent;
      }),
    ),
    primaryColorDark: AppColors.duckEggBlue,
    dividerColor: HexColor('#f3f3f2'),

    ///chat color
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(color: AppColors.blackColor),
      backgroundColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.all(5),
      interactive: true,
      mainAxisMargin: 20,
      thumbVisibility: WidgetStateProperty.all(false),
      radius: const Radius.circular(20),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: AppColors.duckEggBlue,
      collapsedBackgroundColor: AppColors.duckEggBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tilePadding: EdgeInsets.zero,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.greyColor,
      contentTextStyle: AppStyle.textStyle14.copyWith(color: AppColors.white),
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      color: AppColors.duckEggBlue,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
    ),
    outlinedButtonTheme: ButtonsTheme.outlinedButtonLightTheme,
    hintColor: AppColors.blackColor,
    iconTheme: iconTheme,
    inputDecorationTheme: TextFormTheme.inputDecorationLightTheme,
    splashColor: AppColors.white,
    splashFactory: InkSplash.splashFactory,
    scaffoldBackgroundColor: AppColors.white,
    primaryIconTheme: iconTheme,
    textTheme: ThemeData.light().textTheme
        .copyWith(
          headlineSmall: const TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          bodyLarge: const TextStyle(
            fontSize: 14.0,
            color: AppColors.blackColor,
          ),
        )
        .apply(fontFamily: MainAppCubit.instance(context).setFontFamily()),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.duckEggBlue),
  );

  static const iconTheme = IconThemeData(color: AppColors.blackColor);
}
