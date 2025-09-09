import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import '../manager/home_cubit/home_cubit.dart';
import '../widgets/home_bottom_navigation_bar.dart';


class HomeLayoutBody extends StatelessWidget {
  const HomeLayoutBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.instance(context);
        return Scaffold(
          backgroundColor: AppColors.offlineWhite,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: KeyedSubtree(
              key: ValueKey(cubit.currentScreenIndex),
              child: cubit.homeLayoutScreens[cubit.currentScreenIndex],
            ),
          ),
          bottomNavigationBar: HomeBottomNavigationBar(),
          //bottomNavigationBar: const HomeBottomNavigationBar(),
        );
      },
    );
  }
}
