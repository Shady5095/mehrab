import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/students/presentation/manager/edit_student_cubit/edit_student_cubit.dart';

import '../widgets/edit_student_screen_body.dart';

class EditStudentScreen extends StatelessWidget {
  const EditStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return BlocProvider(
      create: (context) => EditStudentCubit(
        userModel: args[0]
      )..fillControllers(),
      child: Scaffold(
        body: EditStudentScreenBody(),
      ),
    );
  }
}
