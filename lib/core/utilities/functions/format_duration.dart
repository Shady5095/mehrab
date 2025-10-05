import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final hours = duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : '';
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$hours$minutes:$seconds';
}

String get generateRandom8DigitNumber {
  final Random random = Random();
  const int min = 10000000; // Minimum 8-digit number
  const int max = 99999999; // Maximum 8-digit number
  return (min + random.nextInt(max - min + 1)).toString();
}
String getDurationString(Timestamp? start, Timestamp? end, bool isArabic) {
  // Check if either timestamp is null
  if (start == null || end == null) {
    return '---';
  }

  // Convert Timestamps to DateTime
  final startDate = start.toDate();
  final endDate = end.toDate();

  // Calculate duration
  final duration = endDate.difference(startDate);

  // Get total hours and minutes
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;

  // Build the formatted string
  String result = '';

  if (isArabic) {
    if (hours > 0) {
      result += '$hours ساعة';
      if (minutes > 0) {
        result += ', $minutes دقيقة';
      }
    } else if (minutes > 0) {
      result = '$minutes دقيقة';
    } else {
      result = '0 دقيقة';
    }
  } else {
    if (hours > 0) {
      result += '$hours hour${hours > 1 ? 's' : ''}';
      if (minutes > 0) {
        result += ', $minutes minute${minutes > 1 ? 's' : ''}';
      }
    } else if (minutes > 0) {
      result = '$minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      result = '0 minutes';
    }
  }

  return result;
}