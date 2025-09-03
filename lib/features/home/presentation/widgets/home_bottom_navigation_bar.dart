import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../../core/utilities/functions/is_dark_mode.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../manager/home_cubit/home_cubit.dart';


class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (pastState, currentState) => currentState is ChangeNavBarState,
      builder: (context, state) {
        final cubit = HomeCubit.instance(context);
        return NavigationBar(

          selectedIndex: cubit.currentScreenIndex,
          onDestinationSelected: cubit.changeNavBar,
          backgroundColor: isDarkMode(context)
              ? AppColors.backgroundGradientDark.last
              : null,
          height: 70,

          destinations: [
            NavigationDestination(
              icon: const Icon(
                CupertinoIcons.home,
              ),
              label: AppStrings.home.tr(context),
            ),
            NavigationDestination(
              icon: const ImageIcon(
                size: 31,
                AssetImage('assets/images/teacher.png'),
              ),
              label: AppStrings.teachers.tr(context),
            ),
            NavigationDestination(
              icon: const Icon(Icons.live_tv_sharp),
              label: AppStrings.sessions.tr(context),
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.menu,
              ),
              label: AppStrings.more.tr(context),
            ),
          ],
        );


      },
    );

  }
}
