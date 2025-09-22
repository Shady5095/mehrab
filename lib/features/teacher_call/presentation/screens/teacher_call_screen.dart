import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/widgets/gradient_scaffold.dart';
import '../manager/teacher_call_cubit.dart';
import '../widgets/teacher_call_screen_body.dart';

class TeacherCallScreen extends StatelessWidget {
  const TeacherCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return PopScope(
      canPop: false,
      child: BlocProvider(
        create: (context) => TeacherCallCubit(
          teacherModel: args[0],
        )..initCall(),
        child: GradientScaffold(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF189AC9),
              Color(0xFF3B85A9),
              Color(0xFF1E8486), // teal accent from original code
              Color(0xFF2FA39C), // teal accent from original code
            ],
          ),
          body: TeacherCallScreenBody(),
        ),
      ),
    );
  }
}
