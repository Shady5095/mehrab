import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/teachers/presentation/manager/teachers_cubit/teachers_cubit.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teachers_list.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teachers_search_bar.dart';

class TeachersScreenBody extends StatelessWidget {
  const TeachersScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    final bool isFav = args.isNotEmpty ? args[0] as bool : false;
    final bool isFromTeacherAcc = args.isNotEmpty ? args[1] as bool : false;
    return BlocProvider(
      create: (context) => TeachersCubit(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: MyAppBar(title: isFav ? AppStrings.favoriteTeachers: AppStrings.teachers, isShowBackButton: isFav || isFromTeacherAcc,),
              ),
              const SizedBox(height: 10,),
               if (!isFav)
               const TeacherSearchBar(),
              if (!isFav)
              const SizedBox(height: 10,),
              const Expanded(
                child: TeachersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
