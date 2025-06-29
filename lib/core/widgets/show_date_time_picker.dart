import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utilities/functions/is_dark_mode.dart';
import '../utilities/resources/colors.dart';

Future<DateTime?> showMyDateTimePicker(
  BuildContext context, {
  DateTime? firstTime,
  DateTime? lastTime,
  DateTime? initialDate,
}) async {
  DateTime? dateTime;
  await showDatePicker(
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) {
      return Theme(data: myDateTimePickerTheme(context), child: child!);
    },
    initialDate: initialDate ?? firstTime ?? DateTime.now(),
    firstDate: firstTime ?? DateTime.now(),
    lastDate: lastTime ?? DateTime(2040),
    context: context,
  ).then((dateValue) async {
    if (dateValue != null) {
      final DateTime date = dateValue;
      await showTimePicker(
        initialEntryMode: TimePickerEntryMode.dialOnly,

        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: Theme(data: myDateTimePickerTheme(context), child: child!),
          );
        },
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((timeValue) {
        if (timeValue != null) {
          final TimeOfDay time = timeValue;
          dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        } else {
          return null;
        }
      });
    } else {
      return null;
    }
  });
  return dateTime;
}

Future<DateTime?> showTest(
  BuildContext context, {
  DateTime? firstTime,
  DateTime? lastTime,
}) async {
  DateTime? dateTime;
  await showDatePicker(
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) {
      return Theme(data: myDateTimePickerTheme(context), child: child!);
    },
    initialDate: firstTime ?? DateTime.now(),
    firstDate: firstTime ?? DateTime(2023),
    lastDate: lastTime ?? DateTime(2040),
    context: context,
  ).then((dateValue) async {
    if (dateValue != null) {

      final DateTime date = dateValue;
      await showTimePicker(
        initialEntryMode: TimePickerEntryMode.dialOnly,

        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: Theme(data: myDateTimePickerTheme(context), child: child!),
          );
        },
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((timeValue) {
        if (timeValue != null) {
          final TimeOfDay time = timeValue;
          dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        } else {
          return null;
        }
      });
    } else {
      return null;
    }
  });
  return dateTime;
}

ThemeData myDateTimePickerTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    colorScheme:
        isDarkMode(context)
            ? const ColorScheme.dark(
              primary: AppColors.accentColor,
              // header background color
              onPrimary: Colors.white,
              // body text color
              surface: AppColors.primaryDarkColor,
              surfaceTint: Colors.white,
              secondary: AppColors.accentColor,
            )
            : const ColorScheme.light(
              primary: AppColors.accentColor,
              // body text color
              surface: AppColors.duckEggBlue,
              surfaceTint: Colors.black,
              secondary: AppColors.accentColor,
            ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentColor, // button text color
      ),
    ),
  );
}

String formatDateTimePicker(BuildContext context, DateTime dateTime) {
  //bool isArabic = !MainAppCubit.instance(context).isEnglish;
  final String formattedDate = DateFormat.yMd('en').format(dateTime);
  final String formattedTime = DateFormat.jm('en').format(dateTime);
  return '$formattedDate, $formattedTime';
}

String formatDatePicker(BuildContext context, DateTime dateTime) {
  //bool isArabic = !MainAppCubit.instance(context).isEnglish;
  final String formattedDate = DateFormat.yMd('en').format(dateTime);
  return formattedDate;
}

Future<DateTime?> showMyDatePicker(
  BuildContext context, {
  DateTime? firstTime,
  DateTime? lastTime,
  DateTime? initialTime,
}) async {
  DateTime? dateTime;
  await showDatePicker(
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) {
      return Theme(data: myDateTimePickerTheme(context), child: child!);
    },
    initialDate: initialTime ?? firstTime ?? DateTime.now(),
    firstDate: firstTime ?? DateTime.now(),
    lastDate: lastTime ?? DateTime(2040),
    context: context,
  ).then((dateValue) async {
    if (dateValue != null) {
      dateTime = dateValue;
    } else {
      return null;
    }
  });
  return dateTime;
}
