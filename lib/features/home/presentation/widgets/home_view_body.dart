import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:mehrab/features/home/presentation/widgets/user_name_and_photo_widget.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/widgets/app_filter_icon.dart';
import 'home_items_icons.dart';
import 'home_items_icons_shimmer.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  String get getGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodNight;
  }

  String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "☀️";
    if (hour < 17) return "🌤️";
    return "🌙";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.instance(context);
        return RefreshIndicator(
          color: AppColors.myAppColor,
          backgroundColor: Colors.white,
          onRefresh: () async {
            cubit.userModel = null;
            cubit.getUserData(context);
          },
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 10.5.hR,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/images/topHome.png'), fit: BoxFit.cover),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: AppFilterIconWithCounter(
                            iconColor: AppColors.white,
                            filterCounter: 2,
                            onTap: () {},
                          ),
                        ),
                        Text(
                          AppStrings.home.tr(context),
                          style: TextStyle(
                            fontSize: 22.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppFilterIconWithCounter(
                          iconColor: AppColors.white,
                          filterCounter: ((cubit.notificationsCount ?? 0) -
                              (CacheService.getData(key: "notificationCount") ?? 0))
                              .toInt(),
                          onTap: () {
                            context
                                .navigateTo(pageName: AppRoutes.notificationsScreen)
                                .then((_) {
                              cubit.refreshNotifications();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CarouselSlider(
                                items: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    child: Image(
                                      image: const AssetImage(AppAssets.welcome2),
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    child: Image(
                                      image: const AssetImage(AppAssets.welcome3),
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    child: Image(
                                      image: const AssetImage(AppAssets.unlimitedTime),
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                                options: CarouselOptions(
                                  viewportFraction: 1.0,
                                  autoPlay: true,
                                  height: 22.hR,
                                  autoPlayInterval: const Duration(seconds: 15),
                                  autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  onPageChanged: (index, reason) {
                                    HomeCubit.instance(context).changeSliderIndex(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Carousel Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final isActive = index == context.watch<HomeCubit>().sliderIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 12 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.myAppColor : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.myAppColor.withValues(alpha: 0.08),
                                    AppColors.coolGreen.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.myAppColor.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              getGreeting.tr(context),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              getGreetingEmoji(),
                                              style: TextStyle(fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        cubit.userModel == null
                                            ? Container(
                                          width: 120,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        )
                                            : Text(
                                          cubit.userModel?.name.firstName ?? '',
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.myAppColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  UserNameAndPhotoWidget(),
                                ],
                              ),
                            ),
                          ),
                          if (cubit.userModel != null &&
                              cubit.userModel?.userRole == "teacher")
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0, left: 20, right: 20),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: cubit.teacherAvailability
                                            ? AppColors.coolGreen.withValues(alpha: 0.1)
                                            : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        cubit.teacherAvailability
                                            ? Icons.check_circle_outline
                                            : Icons.schedule,
                                        color: cubit.teacherAvailability
                                            ? AppColors.coolGreen
                                            : Colors.grey,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.iAmAvailable.tr(context),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            cubit.teacherAvailability
                                                ? "متاح الآن للطلاب"
                                                : "غير متاح حالياً",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.9,
                                      child: Switch(
                                        value: cubit.teacherAvailability,
                                        activeThumbColor: AppColors.coolGreen,
                                        onChanged: (value) {
                                          cubit.changeTeacherAvailability(
                                              value, context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(height: 15),
                          // Items Grid
                          cubit.userModel == null
                              ? HomeItemsIconsShimmer()
                              : HomeItemsIcons(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}