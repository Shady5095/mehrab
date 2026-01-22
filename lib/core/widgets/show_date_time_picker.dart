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
  final dateValue = await showDatePicker(
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) {
      return Theme(data: myDateTimePickerTheme(context), child: child!);
    },
    initialDate: initialDate ?? firstTime ?? DateTime.now(),
    firstDate: firstTime ?? DateTime.now(),
    lastDate: lastTime ?? DateTime(2040),
    context: context,
  );

  if (dateValue == null) return null;

  final timeValue = await showTimePicker(
    initialEntryMode: TimePickerEntryMode.dialOnly,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: Theme(data: myDateTimePickerTheme(context), child: child!),
      );
    },
    context: context,
    initialTime: initialDate != null
        ? TimeOfDay(hour: initialDate.hour, minute: initialDate.minute)
        : TimeOfDay.now(),
  );

  if (timeValue == null) return null;

  return DateTime(
    dateValue.year,
    dateValue.month,
    dateValue.day,
    timeValue.hour,
    timeValue.minute,
  );
}

Future<DateTime?> showTest(
  BuildContext context, {
  DateTime? firstTime,
  DateTime? lastTime,
}) async {
  final dateValue = await showDatePicker(
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) {
      return Theme(data: myDateTimePickerTheme(context), child: child!);
    },
    initialDate: firstTime ?? DateTime.now(),
    firstDate: firstTime ?? DateTime(2023),
    lastDate: lastTime ?? DateTime(2040),
    context: context,
  );

  if (dateValue == null) return null;

  final timeValue = await showTimePicker(
    initialEntryMode: TimePickerEntryMode.dialOnly,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: Theme(data: myDateTimePickerTheme(context), child: child!),
      );
    },
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (timeValue == null) return null;

  return DateTime(
    dateValue.year,
    dateValue.month,
    dateValue.day,
    timeValue.hour,
    timeValue.minute,
  );
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
  final String formattedDate = DateFormat.yMd('ar').format(dateTime);
  final String formattedTime = DateFormat.jm('ar').format(dateTime);
  return '$formattedDate, $formattedTime';
}

String formatDatePicker(BuildContext context, DateTime dateTime) {
  //bool isArabic = !MainAppCubit.instance(context).isEnglish;
  final String formattedDate = DateFormat.yMd('ar').format(dateTime);
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
