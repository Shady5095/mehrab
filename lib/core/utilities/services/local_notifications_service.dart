import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void onTap(NotificationResponse response) {}

  static Future<void> init() async {
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );
    flutterLocalNotificationsPlugin.initialize(
      settings,

      onDidReceiveBackgroundNotificationResponse: onTap,
      onDidReceiveNotificationResponse: onTap,
    );
  }

  static Future<void> simpleNotification({
    required String title,
    required int id,
  }) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'id0',
      'simple Notification',
      priority: Priority.max,
      importance: Importance.max,
    );
    const NotificationDetails details = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(id, title, '', details);
  }

  static Future<void> notificationWithProgress({
    required int progress,
    required String filename,
    required int id,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'upload_channel', // channel id
          'File Upload', // channel name
          channelDescription: 'File Upload Notifications',
          ongoing: true,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          onlyAlertOnce: true,
          icon: '@drawable/upload',

        );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      '$filename Uploading',
      'Progress: $progress%',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
