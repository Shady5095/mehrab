import 'dart:math';

num formatDoubleNumber(num number) {
  // Check if the number is an integer
  if (number is int || number == number.toInt()) {
    return number.toInt();
  } else {
    // If the number has more than 2 decimal places, truncate to 2 decimal places
    final String numberStr = number.toString();
    final int decimalIndex = numberStr.indexOf('.');
    if (decimalIndex != -1 && numberStr.length - decimalIndex - 1 > 2) {
      // Round the number to 2 decimal places
      final double roundedNumber = double.parse(number.toStringAsFixed(2));
      // Check if the rounded number is effectively an integer
      if (roundedNumber == roundedNumber.toInt()) {
        return roundedNumber.toInt();
      } else {
        return roundedNumber;
      }
    } else {
      // If the number already has 2 or fewer decimal places
      if (number == number.toInt()) {
        return number.toInt();
      } else {
        return number;
      }
    }
  }
}

String formatNumberInMarks(num value) {
  return value % 1 == 0 ? value.toInt().toString() : value.toString();
}

String formatGrade(double? value) {
  if (value == null) {
    return '-';
  } else {
    final valueWihTwo = double.parse(value.toStringAsFixed(2));
    final String str = removeZeroFromDouble(valueWihTwo);
    return str;
  }
}

String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  final i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
}

String removeZeroFromDouble(double value) {
  String str = value.toString();
  str = str.replaceAll(RegExp(r'0*$'), ''); // Remove trailing zeros
  str = str.replaceAll(RegExp(r'\.$'), '');
  return str;
}

bool isSizeLessThan50MB({required int bytes, int limit = 50}) {
  final int size = (bytes / 1048576).round();
  if (size > limit) {
    return false;
  }
  return true;
}
