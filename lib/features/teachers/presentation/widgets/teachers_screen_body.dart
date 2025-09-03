import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/dimens.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';

class TeachersScreenBody extends StatelessWidget { 
  const TeachersScreenBody({super.key}); 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          children: [
            MyAppBar(title: AppStrings.teachers,isShowBackButton: false,),

          ],
        ),
      ),
    );
  }
}
