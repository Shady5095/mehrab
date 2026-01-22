import 'dart:io';

import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import '../../app/app_locale/app_locale.dart';
import '../utilities/services/cache_service.dart';

class BuildUpgradeAlert extends StatelessWidget {
  final Widget child;
  const BuildUpgradeAlert({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      barrierDismissible: false,
      showIgnore: false,
      showLater: false,
      dialogStyle: Platform.isAndroid
          ? UpgradeDialogStyle.material
          : UpgradeDialogStyle.cupertino,
      upgrader: Upgrader(
        languageCode: isArabic(context) ? 'ar' : 'en',
        durationUntilAlertAgain: const Duration(seconds: 1),
        countryCode: CacheService.currentCountryCode,
      ),
      child: child,
    );
  }
}
