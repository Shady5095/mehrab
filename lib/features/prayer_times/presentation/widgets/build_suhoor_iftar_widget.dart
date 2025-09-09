import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/utilities/functions/is_dark_mode.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';

class SuhoorIftarWidget extends StatelessWidget {
  final String? suhoorTime;
  final String? iftarTime;

  const SuhoorIftarWidget({
    super.key,
    required this.suhoorTime,
    required this.iftarTime,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color:
            isDarkMode(context)
                ? AppColors.myAppColor.withValues(alpha: 0.15)
                : const Color.fromRGBO(242, 247, 253, 1.0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                AppStrings.suhoor.tr(context),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              buildTimeText(suhoorTime, context),
            ],
          ),
          Container(
            height: 5.5.hR,
            width: 2,
            color:
                isDarkMode(context)
                    ? AppColors.myAppColor.withValues(alpha: 0.3)
                    : const Color.fromRGBO(189, 220, 252, 1.0),
          ),
          Column(
            children: [
              Text(
                AppStrings.iftaar.tr(context),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              buildTimeText(iftarTime, context),
            ],
          ),
        ],
      ),
    );
  }
}
