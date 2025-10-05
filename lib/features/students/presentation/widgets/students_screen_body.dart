import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/dimens.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/students/presentation/widgets/student_search_bar.dart';
import 'package:mehrab/features/students/presentation/widgets/students_list.dart';

class StudentsScreenBody extends StatelessWidget {
  final bool isShowBackButton;

  const StudentsScreenBody({super.key, this.isShowBackButton = true});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          children: [
            MyAppBar(title: AppStrings.students,isShowBackButton: isShowBackButton,),
            const SizedBox(height: 10,),
            const StudentSearchBar(),
            const SizedBox(height: 10),
            const Expanded(
              child: StudentsList(),
            ),
          ],
        ),
      ),
    );
  }
}
