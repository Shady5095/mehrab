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
        'name': AppStrings.favStudents,
        'icon': 'assets/images/student_fav.png',
        'details': cubit.favoriteStudentsCount.toString(),
        'color': AppColors.redColor,
      },
      {
        'name': AppStrings.reviewsAndComments,
        'icon': 'assets/images/teacher_comments.png',
        'details': cubit.teacherRatingAndComments.toString(),
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

    List<Function()> adminOnTapFunctions = [
          () {
        context
            .navigateTo(pageName: AppRoutes.teachersScreen, arguments: [true])
            .then((value) => cubit.getFavoriteTeachersCount());
      },
          () {
        context
            .navigateTo(pageName: AppRoutes.allStudentsScreen)
            .then((value) => cubit.getStudentsCount());
      },
          () {
        context.navigateTo(pageName: AppRoutes.prayerTimesScreen);
      },
          () {
        context.navigateTo(pageName: AppRoutes.quranWebView);
      },
    ];
    List<Function()> studentOnTapFunctions = [
          () {
        context
            .navigateTo(pageName: AppRoutes.teachersScreen, arguments: [true])
            .then((value) => cubit.getFavoriteTeachersCount());
      },
          () {
        context.navigateTo(pageName: AppRoutes.prayerTimesScreen);
      },
          () {
        context.navigateTo(pageName: AppRoutes.quranWebView);
      },
    ];
    List<Function()> teacherOnTapFunctions = [
          () {
        context.navigateTo(
            pageName: AppRoutes.favoriteStudentsScreen, arguments: [true]);
      },
          () {
        context.navigateTo(pageName: AppRoutes.teacherReviewsScreen);
      },
          () {
        context.navigateTo(pageName: AppRoutes.prayerTimesScreen);
      },
          () {
        context.navigateTo(pageName: AppRoutes.quranWebView);
      },
    ];

    // حساب الـ text scale factor لتكبير الارتفاع بناءً عليه
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // حساب childAspectRatio بناءً على text scale
    // كلما كبر الخط، نقلل الـ aspect ratio (يعني البطاقة تبقى أطول)
    final baseAspectRatio = 1.4;
    final adjustedAspectRatio = baseAspectRatio / textScaleFactor.clamp(1.0, 1.5);

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: 20.0 * textScaleFactor.clamp(1.0, 1.2),
          vertical: 10.0 * textScaleFactor.clamp(1.0, 1.2),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15.0 * textScaleFactor.clamp(1.0, 1.2),
          mainAxisSpacing: 15.0 * textScaleFactor.clamp(1.0, 1.2),
          childAspectRatio: adjustedAspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 50.0,
              duration: const Duration(milliseconds: 500),
              child: FadeInAnimation(
                duration: const Duration(milliseconds: 500),
                child: _buildModernGlassContainer(
                  context,
                  items[index]['name']!,
                  items[index]['icon']!,
                  items[index]['details'],
                  items[index]['color'] ?? Colors.black,
                  onTap: AppConstants.isAdmin
                      ? adminOnTapFunctions[index]
                      : AppConstants.isStudent
                      ? studentOnTapFunctions[index]
                      : teacherOnTapFunctions[index],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernGlassContainer(
      BuildContext context,
      String name,
      String iconPath,
      String? details,
      Color color, {
        required Function() onTap,
      }) {
    // الحصول على text scale factor
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // حساب أحجام responsive
    final responsivePadding = 10.0 * textScaleFactor.clamp(1.0, 1.3);
    final responsiveIconPadding = 8.0 * textScaleFactor.clamp(1.0, 1.3);
    final responsiveBorderRadius = 20.0 * textScaleFactor.clamp(1.0, 1.2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsiveBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.05),
              color.withValues(alpha: 0.08),
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(responsiveBorderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.0),
              blurRadius: 5,
              offset: Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Decorative pattern in background
            Positioned(
              left: -15 * textScaleFactor.clamp(1.0, 1.3),
              top: -15 * textScaleFactor.clamp(1.0, 1.3),
              child: Opacity(
                opacity: 0.06,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 80 * textScaleFactor.clamp(1.0, 1.2),
                  color: color,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsivePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon with circular background
                  Container(
                    padding: EdgeInsets.all(responsiveIconPadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.08),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      iconPath,
                      width: 26 * textScaleFactor.clamp(1.0, 1.3),
                      height: 26 * textScaleFactor.clamp(1.0, 1.3),
                      color: name == AppStrings.reviewsAndComments ? null : color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error,
                          size: 26 * textScaleFactor.clamp(1.0, 1.3),
                          color: color,
                        );
                      },
                    ),
                  ),
                  // النصوص مع responsive sizing
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.tr(context),
                                style: TextStyle(
                                  fontSize: name == AppStrings.favoriteTeachers || name == AppStrings.reviewsAndComments || name == AppStrings.favStudents ?12.sp : 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (details != null) ...[
                                SizedBox(height: 1 * textScaleFactor.clamp(1.0, 1.2)),
                                Text(
                                  details == "quran"
                                      ? "اقرأ وتعلّم مع التفسير"
                                      : details == "prayerTimes"
                                      ? "إن الصلاة كانت على المؤمنين كتابًا موقوتًا"
                                      : details,
                                  style: TextStyle(
                                    fontSize: details == "prayerTimes"
                                        ? 8.5
                                        : details == "quran"
                                        ? 11
                                        : 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                    fontFamily: details == "prayerTimes" ||
                                        details == "quran"
                                        ? 'Amiri'
                                        : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(
                              6 * textScaleFactor.clamp(1.0, 1.2)),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                8 * textScaleFactor.clamp(1.0, 1.2)),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14 * textScaleFactor.clamp(1.0, 1.3),
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}