import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';

import '../../../../core/utilities/functions/is_dark_mode.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/services/cache_service.dart';
import '../manager/home_cubit/home_cubit.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.instance(context);
        return NavigationBar(
          selectedIndex: cubit.currentScreenIndex,
          onDestinationSelected: cubit.changeNavBar,
          backgroundColor:
              isDarkMode(context)
                  ? AppColors.backgroundGradientDark.last
                  : null,
          height: 70,

          destinations: [
            NavigationDestination(
              icon: const Icon(CupertinoIcons.home),
              label: AppStrings.home.tr(context),
            ),
            if (cubit.userModel != null)
              NavigationDestination(
                icon: ImageIcon(
                  size: 30.sp,
                  AssetImage(
                    AppConstants.isTeacher
                        ? "assets/images/students.png"
                        : 'assets/images/teacher.png',
                  ),
                ),
                label:
                    AppConstants.isTeacher
                        ? AppStrings.students.tr(context)
                        : AppStrings.teachers.tr(context),
              ),
            if(cubit.userModel != null && AppConstants.isTeacher)
            Stack(
              alignment: Alignment.topLeft,
              children: [
                NavigationDestination(
                  icon: const Icon(Icons.call_outlined),
                  label: AppStrings.calls.tr(context),
                ),
                if ((cubit.missedCallsCount) - (CacheService.getData(key: "missedCallCount")??0) > 0 && cubit.currentScreenIndex != 2)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${((cubit.missedCallsCount)- (CacheService.getData(key: "missedCallCount")??0)).toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            NavigationDestination(
              enabled: cubit.userModel != null,
              icon: const Icon(Icons.live_tv_sharp),
              label: AppStrings.sessions.tr(context),
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu),
              label: AppStrings.more.tr(context),
            ),
          ],
        );
      },
    );
  }
}
