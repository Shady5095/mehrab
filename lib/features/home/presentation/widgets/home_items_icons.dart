import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';

import '../../../../core/utilities/resources/constants.dart';

class HomeItemsIcons extends StatelessWidget {
  const HomeItemsIcons({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = HomeCubit.instance(context);
    final List<Map<String, dynamic>> adminItems = [
      {
        'name': AppStrings.favoriteTeachers,
        'icon': 'assets/images/teacher_fav.png',
        'details': cubit.favoriteTeachersCount.toString(),
        'color': AppColors.redColor,
      },
      {
        'name': AppStrings.students,
        'icon': 'assets/images/students.png',
        'details': cubit.studentsCount.toString(),
        'color': AppColors.accentColor,
      },
      {
        'name': AppStrings.prayerTimes,
        'icon': 'assets/images/pray.png',
        'details': "prayerTimes",
        'color': AppColors.coolGreen,
      },
      {
        'name': AppStrings.quran,
        'icon': 'assets/images/book.png',
        'details': 'quran',
        'color': AppColors.purple,
      },
    ];
    final List<Map<String, dynamic>> studentItems = [
      {
        'name': AppStrings.favoriteTeachers,
        'icon': 'assets/images/teacher_fav.png',
        'details': cubit.favoriteTeachersCount.toString(),
        'color': AppColors.redColor,
      },
      {
        'name': AppStrings.prayerTimes,
        'icon': 'assets/images/pray.png',
        'details': "prayerTimes",
        'color': AppColors.coolGreen,
      },
      {
        'name': AppStrings.quran,
        'icon': 'assets/images/book.png',
        'details': 'quran',
        'color': AppColors.purple,
      },
    ];
    final List<Map<String, dynamic>> teacherItems = [
      {
        'name': AppStrings.favoriteTeachers,
        'icon': 'assets/images/teacher_fav.png',
        'details': cubit.favoriteTeachersCount.toString(),
        'color': AppColors.redColor,
      },
      {
        'name': AppStrings.students,
        'icon': 'assets/images/students.png',
        'details': cubit.studentsCount.toString(),
        'color': AppColors.accentColor,
      },
      {
        'name': AppStrings.prayerTimes,
        'icon': 'assets/images/pray.png',
        'details': "prayerTimes",
        'color': AppColors.coolGreen,
      },
      {
        'name': AppStrings.quran,
        'icon': 'assets/images/book.png',
        'details': 'quran',
        'color': AppColors.purple,
      },
    ];
    final List<Map<String, dynamic>> items = AppConstants.isAdmin
        ? adminItems
        : AppConstants.isStudent
            ? studentItems
            : teacherItems;
    // make on tap for each item to navigate to a new screen
    List<Function()> onTapFunctions = [
      () {
        context.navigateTo(pageName: AppRoutes.teachersScreen,arguments: [true]).then((value) => cubit.getFavoriteTeachersCount());
      },
      () {
        context.navigateTo(pageName: AppRoutes.allStudentsScreen).then((value) => cubit.getStudentsCount());
      },
      () {
        context.navigateTo(pageName: AppRoutes.prayerTimesScreen);
      },
      () {
        context.navigateTo(pageName: AppRoutes.quranWebView);
      },
    ];

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(15.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 items per row
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 1.5, // Square items
        ),
        itemCount: items.length, // Total 4 items
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 50.0,
              duration: const Duration(milliseconds: 500),
              child: FadeInAnimation(
                duration: const Duration(milliseconds: 500),
                child: _buildGlassContainer(
                  context,
                  items[index]['name']!,
                  items[index]['icon']!,
                  items[index]['details'],
                  items[index]['color'] ?? Colors.black,
                  onTap: onTapFunctions[index],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassContainer(
    BuildContext context,
    String name,
    String iconPath,
    String? details,
    Color color, {
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Glass effect with main color
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    iconPath,
                    width: 30.sp,
                    height: 30.sp,
                    color: color,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if asset image fails to load
                      return Icon(Icons.error, size: 30.sp, color: color);
                    },
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20.sp,
                    color: AppColors.myAppColor,
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                name.tr(context),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (details != null)
                Text(
                  details == "quran" ? "اقرأ وتعلّم مع التفسير" : details == "prayerTimes" ? "إن الصلاة كانت على المؤمنين كتابًا موقوتًا" : details,
                  style: TextStyle(
                    fontSize:details == "prayerTimes" ? 10.5.sp : details == "quran" ? 12.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    fontFamily: 'Amiri'
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
