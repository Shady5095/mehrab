import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';

import '../../../../core/utilities/resources/styles.dart';
import 'my_reviews_list.dart';

class TeacherReviewsScreenBody extends StatelessWidget {
  const TeacherReviewsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyAppBar(
              title: AppStrings.myReviewsAndComments,
              titleTextStyle: AppStyle.textStyle28.copyWith(fontSize: 17.sp),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(child: MyReviewsList()),
          ],
        ),
      ),
    );
  }
}
