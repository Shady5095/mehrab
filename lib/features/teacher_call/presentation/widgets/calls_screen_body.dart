import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';

import 'calls_list.dart';

class CallsScreenBody extends StatelessWidget {
  const CallsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          children: [
            MyAppBar(title: AppStrings.calls, isShowBackButton: false),
            const SizedBox(height: 20),
            CallsList(),
          ],
        ),
      ),
    );
  }
}
