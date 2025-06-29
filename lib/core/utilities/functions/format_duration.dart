import 'dart:math';

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
