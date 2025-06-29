import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../app/app_locale/app_locale.dart';
import '../resources/strings.dart';

String formatDate(BuildContext context, String date) {
  if (date.isNotEmpty) {
    return DateFormat(
      'MMMM dd, yyyy',
      isArabic(context) ? 'ar' : 'en',
    ).format(DateTime.parse(date));
  }
  return '';
}

String formatDate2(BuildContext context, String date) {
  if (date.isNotEmpty) {
    return DateFormat(
      'MMM dd, yyyy',
      isArabic(context) ? 'ar' : 'en',
    ).format(DateTime.parse(date));
  }
  return '';
}

String formatDate3(BuildContext context, String date) {
  if (date.isNotEmpty) {
    return DateFormat(
      'dd.MM.yy',
      isArabic(context) ? 'ar' : 'en',
    ).format(DateTime.parse(date));
  }
  return '';
}

String formatVirtualDateTime({
  required String originalDateString,
  int? minutesToAdd,
}) {
  // Parse the original date string
  final DateTime parsedDate = DateTime.parse(originalDateString);

  // Add the specified number of minutes
  DateTime? updatedDate;

  if (minutesToAdd != null) {
    updatedDate = parsedDate.add(Duration(minutes: minutesToAdd));
  }

  // Define the output format
  final DateFormat outputFormat = DateFormat('d MMM, h:mm a');

  // Format the updated date to the desired output format
  final String formattedDate = outputFormat.format(updatedDate ?? parsedDate);

  return formattedDate;
}

String formatTime(BuildContext context, String time) {
  if (time.isNotEmpty) {
    return DateFormat(
      'jm',
      isArabic(context) ? 'ar' : 'en',
    ).format(DateTime.parse(time));
  }
  return '';
}

String formatGivenTime(int seconds, BuildContext context) {
  final int hours = seconds ~/ 3600;
  final int minutes = (seconds % 3600) ~/ 60;
  final int remainingSeconds = seconds % 60;

  String formattedTime = '';

  if (hours > 0) {
    formattedTime += '$hours ${AppStrings.hour.tr(context)}';
  }
  if (minutes > 0) {
    if (hours <= 0) {
      formattedTime += '$minutes ${AppStrings.minutes.tr(context)}';
    } else {
      formattedTime += ',$minutes ${AppStrings.minutes.tr(context)}';
    }
  }
  if (remainingSeconds > 0) {
    if (hours <= 0 && minutes <= 0) {
      formattedTime += '$remainingSeconds ${AppStrings.minutes.tr(context)}';
    } else {
      formattedTime += ',$remainingSeconds ${AppStrings.seconds.tr(context)}';
    }
  }

  return formattedTime.trim();
}

String formatDayTime(int seconds, BuildContext context) {
  final int days = seconds ~/ (3600 * 24);
  int remainingSeconds = seconds % (3600 * 24);
  final int hours = remainingSeconds ~/ 3600;
  remainingSeconds %= 3600;
  final int minutes = remainingSeconds ~/ 60;
  final int remainingSecondsFinal = remainingSeconds % 60;

  String formattedTime = '';

  if (days > 0) {
    formattedTime += '$days ${AppStrings.day.tr(context)}';
    if (hours == 0 && minutes == 0 && remainingSecondsFinal == 0) {
      return formattedTime.trim();
    }
  }
  if (hours > 0) {
    formattedTime += '$hours ${AppStrings.hour.tr(context)}';
  }
  if (days == 0 && minutes > 0) {
    formattedTime += '$minutes ${AppStrings.minutes.tr(context)}';
  }
  if (days == 0 && hours == 0 && remainingSecondsFinal > 0) {
    formattedTime += '$remainingSecondsFinal ${AppStrings.seconds.tr(context)}';
  }

  return formattedTime.trim();
}

bool isDateBeforeNow(String dateString, {DateTime? serverTime}) {
  final DateTime dateTime = DateTime.parse(dateString);
  final DateTime now = serverTime ?? DateTime.now();
  return dateTime.isBefore(now);
}

bool isDateIsAfterOrEqualNow(String dateString, {DateTime? serverTime}) {
  final DateTime dateTime = DateTime.parse(dateString);
  final DateTime now = serverTime ?? DateTime.now();
  return now.isAfter(dateTime) || now.isAtSameMomentAs(dateTime);
}

bool isDateBeforeAnother(
  String date1,
  String date2, {
  String formatString = 'M/d/yyyy, h:mm a',
}) {
  // Parse the date strings into DateTime objects
  if (date1.isNotEmpty && date2.isNotEmpty) {
    final DateFormat format = DateFormat(formatString);
    final DateTime parsedDate1 = format.parse(date1);
    final DateTime parsedDate2 = format.parse(date2);

    // Compare the DateTime objects
    return parsedDate1.isBefore(parsedDate2);
  }
  return true;
}

bool isDateAfterAnother(String date1, String date2) {
  // Parse the date strings into DateTime objects
  if (date1.isNotEmpty) {
    final DateFormat format = DateFormat('M/d/yyyy, h:mm a');
    final DateTime parsedDate1 = format.parse(date1);
    final DateTime parsedDate2 = format.parse(date2);
    // Compare the DateTime objects
    return parsedDate1.isAfter(parsedDate2);
  }
  return false;
}

bool isEnableEditStartDate({required bool isAdd, required String startDate}) {
  if (isAdd) {
    return true;
  } else {
    return !isDateBeforeNow(startDate.toString());
  }
}

String convertTimeFormat(String serverTime) {
  // Parse the server time string to DateTime
  final parsedTime = DateFormat('HH:mm:ss').parse(serverTime);
  // Format the time to 12-hour format (02:00 PM)
  return DateFormat('hh:mm a').format(parsedTime);
}
