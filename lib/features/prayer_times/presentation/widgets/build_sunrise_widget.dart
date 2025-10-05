import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/utilities/functions/is_dark_mode.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart' show AppStrings;

class SunTimesWidget extends StatelessWidget {
  final String? sunriseTime;
  final String? midDayTime;
  final String? sunsetTime;

  const SunTimesWidget({
    super.key,
    required this.sunriseTime,
    required this.midDayTime,
    required this.sunsetTime,
  });

  Widget _buildTimeColumn(String title, String? time, BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDarkMode(context) ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        buildTimeText(time, context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:
            isDarkMode(context)
                ? AppColors.myAppColor.withValues(alpha: 0.15)
                : const Color.fromRGBO(242, 247, 253, 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimeColumn(
            AppStrings.sunrise.tr(context),
            sunriseTime,
            context,
          ),
          Container(
            height: 5.5.hR,
            width: 2,
            color:
                isDarkMode(context)
                    ? AppColors.myAppColor.withValues(alpha: 0.3)
                    : const Color.fromRGBO(189, 220, 252, 1.0),
          ),
          _buildTimeColumn(AppStrings.midDay.tr(context), midDayTime, context),
          Container(
            height: 5.5.hR,
            width: 2,
            color:
                isDarkMode(context)
                    ? AppColors.myAppColor.withValues(alpha: 0.3)
                    : const Color.fromRGBO(189, 220, 252, 1.0),
          ),
          _buildTimeColumn(AppStrings.sunset.tr(context), sunsetTime, context),
        ],
      ),
    );
  }

  Widget buildTimeText(String? time, BuildContext context) {
    // Default value if time is null
    if (time == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '----',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            '',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    // Original logic for when time is not null
    final List<String> parts = time.split(' ');
    final String mainTime = parts.isNotEmpty ? parts[0] : '----';
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
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          amPm,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
