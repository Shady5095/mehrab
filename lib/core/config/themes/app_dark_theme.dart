import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/main_app_cubit/main_app_cubit.dart';
import '../../utilities/resources/colors.dart';
import '../../utilities/resources/styles.dart';
import 'bottom_navigation_bar_theme.dart';
import 'buttons_theme.dart';
import 'text_form_theme.dart';

class AppDarkThemes {
  static ThemeData appDarkTheme(BuildContext context) => ThemeData(
    /// Shimmer
    shadowColor: Colors.grey.shade500,

    secondaryHeaderColor: Colors.white,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.primaryDarkColor,
      modalBackgroundColor: AppColors.primaryDarkColor,
    ),
    dividerColor: Colors.grey[850],

    ///chatColor
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.white,
      iconColor: AppColors.white,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.primaryDarkColor,
      labelStyle: TextStyle(
        color: AppColors.white,
      ),
      selectedColor: AppColors.accentColor,
      secondarySelectedColor: AppColors.accentColor,
      disabledColor: AppColors.greyColor,
      selectedShadowColor: AppColors.accentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    primaryColor: AppColors.primaryDarkColor,
    navigationBarTheme: NavigationBarThemeCustom.darkTheme,
    elevatedButtonTheme: ButtonsTheme.elevatedButtonLightTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentColor,
    ).copyWith(secondary: AppColors.accentColor),
    primaryColorDark: Colors.grey[850],
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(color: AppColors.white),
      backgroundColor: AppColors.primaryDarkColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.primaryDarkColor,
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: AppColors.darkContainerColor,
      collapsedBackgroundColor: AppColors.darkContainerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tilePadding: EdgeInsets.zero,
      textColor: AppColors.white,
      collapsedTextColor: AppColors.white,
      iconColor: AppColors.white,
      collapsedIconColor: AppColors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentColor,
      foregroundColor: AppColors.white,
    ),
    checkboxTheme: ThemeData.dark().checkboxTheme.copyWith(
      side: WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
        // Set the border color when the checkbox is enabled
        if (states.contains(WidgetState.disabled)) {
          return const BorderSide(
            color: Colors.white12,
          ); // Border color when disabled
        } else if (states.contains(WidgetState.selected)) {
          return const BorderSide(
            color: Colors.transparent,
          ); // Border color when error
        }
        return const BorderSide(
          color: AppColors.white,
        ); // Border color when enabled
      }),
      fillColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentColor; // Fill color when selected
        }
        return Colors.transparent; // Fill color when not selected
      }),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.white),
      thickness: WidgetStateProperty.all(5),
      interactive: true,
      mainAxisMargin: 20,
      thumbVisibility: WidgetStateProperty.all(false),
      radius: const Radius.circular(20),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.greyColor,
      contentTextStyle: AppStyle.textStyle14.copyWith(color: AppColors.white),
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      color: AppColors.darkContainerColor,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 5,
    ),
    outlinedButtonTheme: ButtonsTheme.outlinedButtonLightTheme,
    hintColor: AppColors.blueyGrey,
    iconTheme: iconTheme,
    inputDecorationTheme: TextFormTheme.inputDecorationDarkTheme,
    splashColor: AppColors.blackColor,
    splashFactory: InkSplash.splashFactory,
    scaffoldBackgroundColor: AppColors.backgroundGradientDark.last,
    primaryIconTheme: iconTheme,
    textTheme: ThemeData.dark().textTheme
        .copyWith(
          headlineSmall: const TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          bodyLarge: const TextStyle(fontSize: 14.0, color: AppColors.white),
        )
        .apply(
          fontFamily: MainAppCubit.instance(context).setFontFamily(),
          bodyColor: AppColors.white,
        ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.primaryDarkColor,
    ),
  );

  static const iconTheme = IconThemeData(color: AppColors.white);
}
