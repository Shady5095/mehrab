import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../widgets/my_alert_dialog.dart';
import '../../widgets/show_app_dialog.dart';
import '../resources/strings.dart';

Future<void> showExitAppDialog(BuildContext context) async {
  showAnimationToDialog(
    context: context,
    dialog: MyAlertDialog(
      title: AppStrings.exitApp.tr(context),
      onTapYes: SystemNavigator.pop,
      isFailed: true,
    ),
  );
}

void checkToExit(bool conPop, BuildContext context) {
  if (conPop) {
    return;
  }
  showExitAppDialog(context);
}
