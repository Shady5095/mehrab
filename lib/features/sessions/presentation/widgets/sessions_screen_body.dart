import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/sessions/presentation/widgets/sessions_list.dart';

class SessionsScreenBody extends StatelessWidget { 
  const SessionsScreenBody({super.key}); 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            MyAppBar(title: AppStrings.sessions,isShowBackButton: false,),
            const SizedBox(height: 10),
            SessionsList(),
          ],
        ),
      ),
    );
  }
}
