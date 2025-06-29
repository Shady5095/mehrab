import '../resources/constants.dart';
import '../services/cache_service.dart';
import '../services/firebase_notification.dart';

Future<void> deleteAppCache() async {
  await Future.wait([
    CacheService.removeData(key: AppConstants.token),
    CacheService.removeData(key: AppConstants.isParentSelectChild),
    CacheService.removeData(key: AppConstants.userRole),

    CacheService.removeData(key: AppConstants.selectedChild),
    AppFirebaseNotification.deleteNotificationToken(),
    AppFirebaseNotification.unSubscribeFromTopic(),
  ]);
}
