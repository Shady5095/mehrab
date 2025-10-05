import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/utilities/functions/is_dark_mode.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';

class PrayerTimesWidget extends StatefulWidget {
  final String locationName;
  final List<String?> prayerTimes; // Ordered List of Prayer Times
  final String currentPrayer;

  const PrayerTimesWidget({
    super.key,
    required this.locationName,
    required this.prayerTimes,
    required this.currentPrayer,
  });

  @override
  State<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  final List<Map<String, dynamic>> prayerList = [
    {'name': AppStrings.fajr, 'icon': Icons.nights_stay}, // Moon icon
    {'name': AppStrings.duhur, 'icon': Icons.wb_sunny}, // Sun icon
    {'name': AppStrings.asr, 'icon': Icons.wb_sunny_outlined}, // Sun outline
    {'name': AppStrings.maghrib, 'icon': Icons.wb_twilight}, // Sunset icon
    {'name': AppStrings.isha, 'icon': Icons.nightlight_round}, // Night icon
  ];

  Widget _buildTimeText(String? time, bool isCurrent, BuildContext context) {
    if (time == null || time.isEmpty) {
      return Text('---', style: TextStyle(fontSize: 15.sp));
    }

    final List<String> parts = time.split(' ');
    final String mainTime = parts.isNotEmpty ? parts[0] : '---';
    String amPm = parts.length > 1 ? parts[1] : '';

    // Check if Arabic and replace AM/PM with ص / م
    if (isArabic(context)) {
      if (amPm.toLowerCase() == 'am') {
        amPm = 'ص';
      } else if (amPm.toLowerCase() == 'pm') {
        amPm = 'م';
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          mainTime.trim(),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            color: isCurrent ? AppColors.myAppColor : null,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          amPm.trim(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isCurrent ? AppColors.myAppColor : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode(context)
                ? AppColors.myAppColor.withValues(alpha: 0.15)
                : const Color.fromRGBO(242, 247, 253, 1.0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                size: 25.sp,
              ),
              const SizedBox(width: 6),
              Text(
                widget.locationName,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(prayerList.length, (index) {
              final String prayerName = prayerList[index]['name'];
              final String? time =
                  index < widget.prayerTimes.length
                      ? widget.prayerTimes[index]
                      : null;
              final bool isCurrent = widget.currentPrayer == prayerName;

              return Column(
                children: [
                  Divider(
                    color:
                        isDarkMode(context) ? Colors.white12 : Colors.black12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              prayerList[index]['icon'],
                              color:
                                  isCurrent
                                      ? AppColors.myAppColor
                                      : (isDarkMode(context)
                                          ? Colors.white54
                                          : Colors.black54),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              prayerName.tr(context),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight:
                                    isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color: isCurrent ? AppColors.myAppColor : null,
                              ),
                            ),
                          ],
                        ),
                        _buildTimeText(time, isCurrent, context),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
