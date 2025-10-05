import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/my_teacher_profile_cubit.dart';
import '../widgets/change_password_screen_body_teacher.dart';

class ChangePasswordScreenTeacher extends StatelessWidget {
  const ChangePasswordScreenTeacher({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> arguments = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    return BlocProvider.value(
      value: MyTeacherProfileCubit.instance(arguments[0]),
      child: Scaffold(
        body: ChangePasswordScreenBodyTeacher(),
      ),
    );
  }
}
