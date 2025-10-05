import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/student_profile_cubit/students_profile_cubit.dart';
import '../widgets/students_profile_screen_body.dart';

class StudentsProfileScreen extends StatelessWidget {
  const StudentsProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args =
    ModalRoute
        .of(context)!
        .settings
        .arguments as List<dynamic>;
    return BlocProvider(
      lazy: false,
      create: (context) => StudentsProfileCubit(),
      child: Scaffold(
        body: StudentsProfileScreenBody(model: args[0],),
      ),
    );
  }
}
