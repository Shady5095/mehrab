import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

import '../resources/constants.dart';
import 'cache_service.dart';

class RateAppService {
  // Singleton pattern

  static Future<void> showRateAppDialog() async {
    final bool? hasRated = CacheService.getData(
      key: AppConstants.isUserRateApp,
    );

    if (hasRated == null) {
      final InAppReview inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable() && !kDebugMode) {
        await inAppReview.requestReview();
      }

      CacheService.setData(key: AppConstants.isUserRateApp, value: true);
    }
  }
}
