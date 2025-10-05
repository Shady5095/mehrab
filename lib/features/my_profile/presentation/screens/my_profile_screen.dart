import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/my_profile/presentation/manager/my_profile_cubit.dart';
import '../widgets/my_profile_screen_body.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    return BlocProvider(
      create: (context) => MyProfileCubit(
        userModel: args.isNotEmpty ? args[0] : null, // Ensure userModel is not null
      )..fillAllFieldsFromModel(),
      child: Scaffold(
        body: MyProfileScreenBody(),
      ),
    );
  }
}
