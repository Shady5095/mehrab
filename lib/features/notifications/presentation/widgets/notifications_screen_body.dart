import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';

import 'notification_list.dart';

class NotificationsScreenBody extends StatelessWidget { 
  const NotificationsScreenBody({super.key}); 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyAppBar(title: AppStrings.notifications),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: NotificationList(),
            ),

          ],
        ),
      ),
    );
  }
}
