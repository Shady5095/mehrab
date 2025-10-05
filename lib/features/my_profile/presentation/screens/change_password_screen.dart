import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/my_profile/presentation/manager/my_profile_cubit.dart';

import '../widgets/change_password_screen_body.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> arguments = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    return BlocProvider.value(
      value: MyProfileCubit.instance(arguments[0]),
      child: Scaffold(
        body: ChangePasswordScreenBody(),
      ),
    );
  }
}
