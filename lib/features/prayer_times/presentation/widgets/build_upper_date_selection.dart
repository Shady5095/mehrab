import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/show_date_time_picker.dart';

class BuildUpperDateSelection extends StatefulWidget {
  final Function(String) onDateSelected;

  const BuildUpperDateSelection({super.key, required this.onDateSelected});

  @override
  BuildUpperDateSelectionState createState() =>
      BuildUpperDateSelectionState();
}

class BuildUpperDateSelectionState extends State<BuildUpperDateSelection> {
  DateTime _currentDate = DateTime.now();
  late HijriCalendar _hijriDate;

  @override
  void initState() {
    super.initState();
    _updateHijriDate();
  }

  void _updateHijriDate() {
    setState(() {
      _hijriDate = HijriCalendar.fromDate(
        _currentDate,
      );
      final String formattedDate = DateFormat(
        'dd-MM-yyyy',
      ).format(_currentDate);
      widget.onDateSelected(formattedDate);
    });
  }

  void _changeDate(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
      _updateHijriDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const MyBackButton(),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _changeDate(-1),
            color: AppColors.myAppColor,
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showMyDatePicker(context);
              if (picked != null && picked != _currentDate) {
                setState(() {
                  _currentDate = picked;
                  _updateHijriDate();
                });
              }
            },
            child: Column(
              children: [
                Text(
                  DateFormat(
                    'dd MMMM yyyy',
                    isArabic(context) ? 'ar' : 'en',
                  ).format(_currentDate),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_hijriDate.hDay} ${_hijriDate.longMonthName}, ${_hijriDate.hYear}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.greyBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeDate(1),
            color: AppColors.myAppColor,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
