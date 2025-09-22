import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/core/utilities/services/firebase_private_key.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';

import '../functions/print_with_color.dart';
import '../resources/constants.dart';

class AppFirebaseNotification {
  static final _instance = FirebaseMessaging.instance;
  static final _analyticsInstance = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analyticsInstance);
  }

  static final Dio _dio = Dio(
    BaseOptions(
      contentType: Headers.jsonContentType,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      baseUrl:
          'https://fcm.googleapis.com/v1/projects/mehrab-a8e60/messages:send',
    ),
  );
  static late String accessToken;

  static Future<void> initNotification(BuildContext context, HomeCubit homeCubit) async {
    await notificationPermission;
    if (context.mounted) {
      whileAppOpenHandleNotification(homeCubit);
      whileAppCloseHandleNotification(context);
      whileAppOnBackgroundHandleNotification(context);
      getAccessToken();
      _analyticsInstance.setAnalyticsCollectionEnabled(true);
      if (Platform.isAndroid) {
        androidNotificationChannelForPopUpNotification();
      }
    }
  }


  static void whileAppOpenHandleNotification(HomeCubit homeCubit) {
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        homeCubit.getNotificationsCount(); // Use the passed HomeCubit
      }
    });
  }

  static Future<void> get notificationPermission async {
    await _instance.requestPermission(announcement: true);
  }

  static Future<void> whileAppCloseHandleNotification(
    BuildContext context,
  ) async {
    await _instance.getInitialMessage().then((message) {
      if (message != null && context.mounted){
        onTabNotification(message, context);
      }
    });
  }

  static Future<void> whileAppOnBackgroundHandleNotification(
    BuildContext context,
  ) async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        if (!context.mounted) return;
        onTabNotification(message, context);
      }
    });
  }


  static Future<void> androidNotificationChannelForPopUpNotification() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      // description
      importance: Importance.max,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "mehrab-a8e60",
      "private_key_id": "7d0bafe44af019f11fa73ec5b870befb1b5987c5",
      "private_key": privateKeyNotifications,
      "client_email": "firebase-adminsdk-fbsvc@mehrab-a8e60.iam.gserviceaccount.com",
      "client_id": "117743556891008027326",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40mehrab-a8e60.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    final List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    try {
      final http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );
      final auth.AccessCredentials credentials = await auth
          .obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client,
          );
      client.close();
      accessToken = credentials.accessToken.data;
      return credentials.accessToken.data;
    } on Exception {
      return '';
    }
  }

  static Future<void> pushNotification({
    required String title,
    required String body,
    String? imageUrl,
    required Map<String, dynamic> dataInNotification,
    required String topic,
  }) async {
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/mehrab-a8e60/messages:send';
    final Map<String, dynamic> data = {
      'message': {
        'topic': topic,
        'notification': {'title': title, 'body': body, 'image': imageUrl ?? ''},
        'data': dataInNotification,
        'android': {
          'notification': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
        },
        'apns': {
          'payload': {
            'aps': {'category': 'FLUTTER_NOTIFICATION_CLICK'},
          },
        },
      },
    };
    try {
      await _dio.post(fcmUrl, data: data);
    } on DioException catch (e) {
      printWithColor('Push notification error: ${e.response?.data}');
      if (e.response?.statusCode == AppConstants.unauthenticated) {
        await getAccessToken();
        await pushNotification(
          title: title,
          body: body,
          imageUrl: imageUrl,
          dataInNotification: dataInNotification,
          topic: topic
        );
      }
    }
  }

  static subscribeToTopic(String role) {
    _instance.subscribeToTopic('all');
    _instance.subscribeToTopic(role);
    _instance.subscribeToTopic(CacheService.uid ?? 'all');
  }

  static Future<void> deleteNotificationToken() async {
    await _instance.deleteToken().catchError((onError) {});
  }

  static Future<void> unSubscribeFromTopic(String role) async {
    _instance.unsubscribeFromTopic('all');
    _instance.unsubscribeFromTopic(role);
    _instance.unsubscribeFromTopic(CacheService.uid ?? 'all');
  }

  static logEvent(String eventName, Map<String, Object> eventParams) {
    _analyticsInstance.logEvent(name: eventName, parameters: eventParams);
  }
  static void onTabNotification(RemoteMessage? message,BuildContext context) {
    if (message != null) {
      if(message.data['type'] == 'notification'){
        context.navigateTo(pageName: AppRoutes.notificationsScreen);
      }else if(message.data['type'] == 'studentRate'){
        context.navigateTo(pageName: AppRoutes.teacherReviewsScreen);
      } else if(message.data['type'] == 'studentFavorite'){
        context.navigateTo(pageName: AppRoutes.favoriteStudentsScreen);
      }
    }
  }
}
