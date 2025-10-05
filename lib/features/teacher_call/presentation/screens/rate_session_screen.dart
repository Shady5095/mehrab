import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/teacher_call/presentation/widgets/rate_session_screen_body.dart';

import '../manager/rate_session_cubit/rate_session_cubit.dart';

class RateSessionScreen extends StatelessWidget {
  const RateSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return BlocProvider(
      create: (context) => RateSessionCubit(
        callModel: args[0],
        isEditMode: args[1] as bool,
      )..fillControllersWithExistingData(context),
      child: Scaffold(
        body: RateSessionScreenBody(),
      ),
    );
  }
}
