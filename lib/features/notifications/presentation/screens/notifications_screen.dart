import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/notifications/presentation/manager/notifications_cubit/notifications_cubit.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../widgets/notifications_screen_body.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsCubit(),
      child: Scaffold(
        backgroundColor: AppColors.offlineWhite,
        body: NotificationsScreenBody(),
        floatingActionButton: NotificationFloatingActionButton(),
      ),
    );
  }
}

class NotificationFloatingActionButton extends StatelessWidget {
  const NotificationFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.isAdmin) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: RawMaterialButton(
        onPressed: () {
          context.navigateTo(pageName: AppRoutes.addNotificationScreen);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        fillColor: AppColors.myAppColor,
        splashColor: AppColors.myAppColor.withValues(alpha: 0.2),
        highlightColor: AppColors.myAppColor,
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints.tightFor(width: 60.0, height: 60.0),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
    );
  }
}