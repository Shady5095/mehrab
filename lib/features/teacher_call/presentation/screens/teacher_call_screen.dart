import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/widgets/gradient_scaffold.dart';
import '../manager/teacher_call_cubit/teacher_call_cubit.dart';
import '../widgets/teacher_call_screen_body.dart';

class TeacherCallScreen extends StatelessWidget {
  const TeacherCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return PopScope(
      canPop: false, // Prevent back button
      child: BlocProvider(
        create: (context) => TeacherCallCubit(
          callModel: args[0],
        )..initCall(),
        child: GradientScaffold(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5bafa5),
              Color(0xFF3a848a),
              Color(0xff2d787e),
              Color(0xFF3a848a),
              Color(0xFF5bafa5),
            ],
          ),
          body: TeacherCallScreenBody(),
        ),
      ),
    );
  }
}
