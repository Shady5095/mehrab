import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/utilities/functions/is_dark_mode.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';

class BuildNowPrayerNextPrayer extends StatelessWidget {
  final String? currentPrayerName;
  final String? currentPrayerTime;
  final String? nextPrayerName;
  final String? nextPrayerTime;

  const BuildNowPrayerNextPrayer({
    super.key,
    required this.currentPrayerName,
    required this.currentPrayerTime,
    required this.nextPrayerName,
    required this.nextPrayerTime,
  });

  Widget _buildPrayerContainer({
    required String title,
    required String prayerName,
    required String prayerTime,
    required List<Color> colors,
    required BuildContext context,
  }) {
    return Expanded(
      child: Container(
        height: 20.hR,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: colors,
            begin: AlignmentDirectional.topEnd,
            end: AlignmentDirectional.bottomStart,
          ),
          image: DecorationImage(
            opacity: isDarkMode(context) ? 0.5 : 0.3,
            //alignment: AlignmentDirectional.bottomStart,
            image: const AssetImage('assets/images/prayerBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode(context) ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prayerName.tr(context),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.myAppColor,
              ),
            ),
            buildTimeText(prayerTime, context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPrayerContainer(
          context: context,
          title: AppStrings.nowTimeIs.tr(context),
          prayerName: currentPrayerName ?? '---',
          prayerTime: currentPrayerTime ?? '---',
          colors:
              isDarkMode(context)
                  ? [
                    AppColors.myAppColor.withValues(alpha: 0.3),
                    AppColors.myAppColor.withValues(alpha: 0.25),
                    AppColors.myAppColor.withValues(alpha: 0.2),
                    AppColors.myAppColor.withValues(alpha: 0.1),
                  ]
                  : [
                const Color.fromRGBO(138, 206, 202, 1.0),  // softer
                const Color.fromRGBO(184, 226, 224, 1.0),  // pale
                const Color.fromRGBO(229, 246, 245, 1.0),  // very light
                  ],
        ),
        const SizedBox(width: 12),
        _buildPrayerContainer(
          context: context,
          title: AppStrings.nextPrayerIs.tr(context),
          prayerName: nextPrayerName ?? '---',
          prayerTime: nextPrayerTime ?? '---',
          colors:
              isDarkMode(context)
                  ? [
                    Colors.grey.withValues(alpha: 0.3),
                    Colors.grey.withValues(alpha: 0.2),
                    Colors.grey.withValues(alpha: 0.1),
                    Colors.grey.withValues(alpha: 0.05),
                  ]
                  : [
                    const Color.fromRGBO(243, 246, 252, 1.0),
                    const Color.fromRGBO(243, 246, 252, 1.0),
                  ],
        ),
      ],
    );
  }

  Widget buildTimeText(String time, BuildContext context) {
    final List<String> parts = time.split(' ');
    final String mainTime = parts.isNotEmpty ? parts[0] : '---';
    String amPm = parts.length > 1 ? parts[1] : '';

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
          mainTime,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          amPm,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
