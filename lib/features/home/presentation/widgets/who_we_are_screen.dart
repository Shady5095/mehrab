import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/widgets/back_button.dart';
import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/utilities/resources/assets.dart';
import '../../../../core/utilities/resources/strings.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildMainContent(context),
              _buildFeaturesSection(context),
              _buildPathsSection(context),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topEnd,
          end: AlignmentDirectional.bottomStart,
          colors: [
            Color(0xff35a9a2),
            Color(0xff2d787e),
            Color(0xff145374),

          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20,right: 20,),
                  child: MyBackButton(),
                ),
              ],
            ),
            Center(
              child: Image(
                image: AssetImage(AppAssets.appLogoWhite),
                width: 30.wR,
                height: 30.wR,
              ),
            ),
            SizedBox(height: 1.hR),
            Text(
              AppStrings.aboutUsSubtitle.tr(context),
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 1.hR),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.wR),
              child: Text(
                AppStrings.platformDescription.tr(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 3.hR),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.wR),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6.wR),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  AppStrings.quranVerse.tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5E20),
                    height: 2,
                  ),
                ),
                SizedBox(height: 1.hR),
                Text(
                  AppStrings.verseReference.tr(context),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.hR),
          Container(
            padding: EdgeInsets.all(5.wR),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  size: 40.sp,
                  color: const Color(0xFFE91E63),
                ),
                SizedBox(height: 2.hR),
                Text(
                  AppStrings.dedication.tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5E20),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.wR, vertical: 0),
      child: Column(
        children: [
          Text(
            AppStrings.platformFeatures.tr(context),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
          ),
          SizedBox(height: 3.hR),
          _buildFeatureCard(
            context,
            icon: Icons.access_time,
            titleKey: AppStrings.feature1Title,
            descKey: AppStrings.feature1Desc,
            color: const Color(0xFF2196F3),
          ),
          SizedBox(height: 2.hR),
          _buildFeatureCard(
            context,
            icon: Icons.school,
            titleKey: AppStrings.feature2Title,
            descKey: AppStrings.feature2Desc,
            color: const Color(0xFF4CAF50),
          ),
          SizedBox(height: 2.hR),
          _buildFeatureCard(
            context,
            icon: Icons.videocam,
            titleKey: AppStrings.feature3Title,
            descKey: AppStrings.feature3Desc,
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String titleKey,
        required String descKey,
        required Color color,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.wR),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.wR),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32.sp,
              color: color,
            ),
          ),
          SizedBox(width: 4.wR),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKey.tr(context),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF212121),
                  ),
                ),
                SizedBox(height: 0.5.hR),
                Text(
                  descKey.tr(context),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF757575),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(5.wR),
      padding: EdgeInsets.all(6.wR),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff35a9a2),
            Color(0xff2d787e),
            Color(0xff145374),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.availablePaths.tr(context),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.hR),
          _buildPathItem(context, Icons.check_circle, AppStrings.path1),
          SizedBox(height: 1.hR),
          _buildPathItem(context, Icons.check_circle, AppStrings.path2),
          SizedBox(height: 1.hR),
          _buildPathItem(context, Icons.check_circle, AppStrings.path3),
        ],
      ),
    );
  }

  Widget _buildPathItem(BuildContext context, IconData icon, String textKey) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFFD700),
          size: 24.sp,
        ),
        SizedBox(width: 3.wR),
        Expanded(
          child: Text(
            textKey.tr(context),
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.wR),
      color: Color(0xff2d787e),
      child: Column(
        children: [
          Icon(
            Icons.access_time_filled,
            color: const Color(0xFFFFD700),
            size: 32.sp,
          ),
          SizedBox(height: 1.hR),
          Text(
            AppStrings.availableTime.tr(context),
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.hR),
        ],
      ),
    );
  }
}