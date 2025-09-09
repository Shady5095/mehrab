class PrayerTimesEntity {
  final String locationName;
  final String fajrTime;
  final String duhurTime;
  final String asrTime;
  final String maghribTime;
  final String ishaTime;
  final String sunriseTime;
  final String midNightTime;
  final String sunsetTime;
  String? currentPrayerName;
  String? currentPrayerTime;
  String? nextPrayerName;
  String? nextPrayerTime;

  PrayerTimesEntity({
    required this.locationName,
    required String fajrTime,
    required String duhurTime,
    required String asrTime,
    required String maghribTime,
    required String ishaTime,
    required String sunriseTime,
    required String midNightTime,
    required String sunsetTime,
    this.currentPrayerName,
    this.currentPrayerTime,
    this.nextPrayerName,
    this.nextPrayerTime,
  }) : fajrTime = _convertTo12HourFormat(fajrTime),
       duhurTime = _convertTo12HourFormat(duhurTime),
       asrTime = _convertTo12HourFormat(asrTime),
       maghribTime = _convertTo12HourFormat(maghribTime),
       ishaTime = _convertTo12HourFormat(ishaTime),
       sunriseTime = _convertTo12HourFormat(sunriseTime),
       midNightTime = _convertTo12HourFormat(midNightTime),
       sunsetTime = _convertTo12HourFormat(sunsetTime) {
    _setCurrentAndNextPrayer();
  }

  // Helper method to convert 24-hour format to 12-hour format with AM/PM
  static String _convertTo12HourFormat(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts[1];

    final period = (hour >= 12) ? 'PM' : 'AM';
    final hour12 = (hour % 12 == 0) ? 12 : hour % 12;

    return '$hour12:$minute $period';
  }

  void _setCurrentAndNextPrayer() {
    final now = DateTime.now();
    final prayerMap = {
      'fajr': fajrTime,
      'duhur': duhurTime,
      'asr': asrTime,
      'maghrib': maghribTime,
      'isha': ishaTime,
    };

    final Map<String, DateTime> prayerDateTimeMap = {};
    prayerMap.forEach((name, timeStr) {
      final timeParts = timeStr.split(' ');
      final mainTime = timeParts[0].split(':');
      final hour =
          int.parse(mainTime[0]) % 12 + (timeParts[1] == 'PM' ? 12 : 0);
      final minute = int.parse(mainTime[1]);
      final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);
      prayerDateTimeMap[name] = prayerTime;
    });

    final sortedPrayers =
        prayerDateTimeMap.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    for (var i = sortedPrayers.length - 1; i >= 0; i--) {
      if (now.isAfter(sortedPrayers[i].value) ||
          now.isAtSameMomentAs(sortedPrayers[i].value)) {
        currentPrayerName = sortedPrayers[i].key;
        currentPrayerTime = prayerMap[currentPrayerName]!;
        break;
      }
    }

    if (currentPrayerName == null) {
      currentPrayerName = 'isha';
      currentPrayerTime = ishaTime;
    }

    for (var entry in sortedPrayers) {
      if (now.isBefore(entry.value)) {
        nextPrayerName = entry.key;
        nextPrayerTime = prayerMap[nextPrayerName]!;
        break;
      }
    }

    if (nextPrayerName == null) {
      nextPrayerName = 'fajr';
      nextPrayerTime = fajrTime;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'locationName': locationName,
      'fajrTime': fajrTime,
      'duhurTime': duhurTime,
      'asrTime': asrTime,
      'maghribTime': maghribTime,
      'ishaTime': ishaTime,
      'sunriseTime': sunriseTime,
      'midNightTime': midNightTime,
      'sunsetTime': sunsetTime,
      'currentPrayerName': currentPrayerName,
      'currentPrayerTime': currentPrayerTime,
      'nextPrayerName': nextPrayerName,
      'nextPrayerTime': nextPrayerTime,
    };
  }
}
