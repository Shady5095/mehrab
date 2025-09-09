import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/teacher_profile_cubit/teacher_profile_cubit.dart';
import '../widgets/teachers_profile_screen_body.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args =
    ModalRoute
        .of(context)!
        .settings
        .arguments as List<dynamic>;
    return BlocProvider(
      lazy: false,
      create: (context) => TeacherProfileCubit(),
      child: Scaffold(
        body: TeachersProfileScreenBody(model: args[0],),
      ),
    );
  }
}
