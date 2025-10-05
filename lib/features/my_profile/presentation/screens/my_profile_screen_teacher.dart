import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/my_teacher_profile_cubit.dart';
import '../widgets/my_teacher_profile_screen_body.dart';

class MyProfileScreenTeacher extends StatelessWidget {
  const MyProfileScreenTeacher({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    return BlocProvider(
      create: (context) => MyTeacherProfileCubit(
        teacherModel: args.isNotEmpty ? args[0] : null, // Ensure userModel is not null
      )..fillAllFieldsFromModel(),
      child: Scaffold(
        body: MyTeacherProfileScreenBody(),
      ),
    );
  }
}
