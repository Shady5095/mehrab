import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/notifications/presentation/manager/add_notification_cubit/add_notification_cubit.dart';

import '../widgets/add_notification_screen_body.dart';

class AddNotificationScreen extends StatelessWidget {
  const AddNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic>? args = ModalRoute.of(context)!.settings.arguments as List?;
    return BlocProvider(
      create: (context) => AddNotificationCubit(oneUserModel:args == null ? null :args[0]),
      child: Scaffold(
        body: AddNotificationScreenBody(),
      ),
    );
  }
}
