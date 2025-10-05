import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';

import '../../../../core/utilities/resources/styles.dart';
import 'favorite_students_list.dart';

class FavoriteStudentsScreenBody extends StatelessWidget {
  const FavoriteStudentsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyAppBar(
              title: AppStrings.studentWhoAreAddedYouInFav,
              titleTextStyle: AppStyle.textStyle28.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 15,),
            Expanded(child: FavoriteStudentsList()),
          ],
        ),
      ),
    );
  }
}
