import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../manager/home_cubit/home_cubit.dart';
import '../widgets/account_deleted_dialog.dart';
import '../widgets/home_bottom_navigation_bar.dart';
import '../widgets/more_screen_body.dart';


class HomeLayoutBody extends StatelessWidget {
  const HomeLayoutBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if(state is AccountWasDeleted){
          deleteAppCache();
          FirebaseAuth.instance.signOut();
          //HomeCubit.instance(context).onSignOut();
          if (!context.mounted) {
            return;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.navigateAndRemoveUntil(
              pageName: AppRoutes.loginRoute,
            );
            showDialog(context: context, builder: (context)=>AccountDeletedDialog());
          });
        }
      },
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
              child: AppConstants.isTeacher ? cubit.homeLayoutScreensForTeachers[cubit.currentScreenIndex]:cubit.homeLayoutScreens[cubit.currentScreenIndex],
            ),
          ),
          bottomNavigationBar: HomeBottomNavigationBar(),
          //bottomNavigationBar: const HomeBottomNavigationBar(),
        );
      },
    );
  }
}
