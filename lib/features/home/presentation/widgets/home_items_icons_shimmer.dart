import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/shimmer_rectangle_widget.dart';

class HomeItemsIconsShimmer extends StatelessWidget {
  const HomeItemsIconsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for icons and names
    final List<Map<String, dynamic>> items = [
      {
        'name': AppStrings.favoriteTeachers,
        'icon': 'assets/images/teacher_fav.png',
        'details': '0',
        'color': AppColors.redColor,
      },
      {
        'name': AppStrings.students,
        'icon': 'assets/images/students.png',
        'details': '0',
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
    // make on tap for each item to navigate to a new screen
    List<Function()> onTapFunctions = [
      () {

      },
      () {

      },
      () {

      },
      () {

      },
    ];

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Glass effect with main color
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ShimmerRectangleWidget(),
    );
  }
}
