import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/teacher_call/presentation/widgets/rate_session_screen_body.dart';

import '../manager/rate_session_cubit/rate_session_cubit.dart';

class RateSessionScreen extends StatelessWidget {
  const RateSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    // Handle case where arguments are null or invalid
    if (arguments == null || arguments is! List<dynamic> || arguments.isEmpty || arguments[0] == null) {
      // Navigate back if no valid call data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<dynamic> args = arguments;
    bool isEditMode = args[1] as bool;
    return PopScope(
      canPop: isEditMode,
      child: BlocProvider(
        create: (context) => RateSessionCubit(
          callModel: args[0],
          isEditMode: isEditMode,
          isFromCall: args[2] as bool,
        )..fillControllersWithExistingData(context)..checkIfConnectionError(),
        child: Scaffold(
          body: RateSessionScreenBody(),
        ),
      ),
    );
  }
}
