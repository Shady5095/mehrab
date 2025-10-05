import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/teachers/presentation/manager/add_teacher_cubit/add_teacher_cubit.dart';

import '../widgets/add_teacher_screen_body.dart';

class AddTeacherScreen extends StatelessWidget {
  const AddTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return BlocProvider(
      create: (context) => AddTeacherCubit(teacherModel: args[0])..generatePassword()..convertModelToEditing(),
      child: Scaffold(
        body: AddTeacherScreenBody(),
      ),
    );
  }
}
