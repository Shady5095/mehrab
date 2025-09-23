import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/teacher_call/presentation/manager/calls_cubit/calls_cubit.dart';

import '../widgets/calls_screen_body.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CallsCubit(),
      child: Scaffold(
        body: const CallsScreenBody(),
      ),
    );
  }
}
