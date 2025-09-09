import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:mehrab/features/home/presentation/widgets/user_name_and_photo_widget.dart';

import '../../../../core/widgets/app_filter_icon.dart';
import 'home_items_icons.dart';
import 'home_items_icons_shimmer.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.instance(context);
        return Column(
          children: [
            Container(
              width: double.infinity,
              height: 9.hR,
              color: AppColors.myAppColor,
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
                    filterCounter: 2,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            CarouselSlider(
              items: [
                Image(
                  image: const AssetImage(AppAssets.unlimitedTime),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Image(
                  image: const AssetImage(AppAssets.welcome2),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
              options: CarouselOptions(
                viewportFraction: 1.0,
                autoPlay: true,
                height: 200,
                autoPlayInterval: const Duration(seconds: 15),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                onPageChanged: (index, reason) {
                  HomeCubit.instance(context).changeSliderIndex(index);
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
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
            SizedBox(height: 20),
            UserNameAndPhotoWidget(),
            SizedBox(height: 20),
            Expanded(child: cubit.userModel == null ? HomeItemsIconsShimmer() : HomeItemsIcons()),
          ],
        );
      },
    );
  }
}
