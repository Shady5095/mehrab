import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/students/presentation/manager/students_cubit/students_cubit.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../widgets/students_screen_body.dart';

class StudentsScreen extends StatelessWidget {
  final bool isShowBackButton;
  const StudentsScreen({super.key, this.isShowBackButton = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudentsCubit(),
      child: Scaffold(
        backgroundColor: AppColors.offlineWhite,
        body: StudentsScreenBody(isShowBackButton: isShowBackButton,),
      ),
    );
  }
}