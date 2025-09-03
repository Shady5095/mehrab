import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:mehrab/core/utilities/services/cache_service.dart';

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
          'https://fcm.googleapis.com/v1/projects/learnovia-notifications/messages:send',
    ),
  );
  static late String accessToken;

  static Future<void> initNotification(BuildContext context) async {
    await notificationPermission;
    if (context.mounted) {
      whileAppOpenHandleNotification(context);
      whileAppCloseHandleNotification(context);
      whileAppOnBackgroundHandleNotification(context);
      subscribeToTopic();
      getAccessToken();
      _analyticsInstance.setAnalyticsCollectionEnabled(true);
      if (Platform.isAndroid) {
        androidNotificationChannelForPopUpNotification();
      }
    }
  }


  static void whileAppOpenHandleNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((_) {
      if (!context.mounted) return;

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

      }
    });
  }

  static Future<void> whileAppOnBackgroundHandleNotification(
    BuildContext context,
  ) async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        if (!context.mounted) return;

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
      'type': 'service_account',
      'project_id': 'learnovia-notifications',
      'private_key_id': '8bcfee045038844326dd3e5c11204c44a22b3125',
      'private_key':
          '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC5tXZ66/n9jD0z\noYzEaZMJrYSvDf+0IioL8k8UR50u5iY4oW8Do1MbJ9kKGtstPEWop/06hHdHGeVV\n8NWH5UMhH9OgnCqkQfFRzSlClOwX9OE7EwQ9jgm0eO8H6/gJlqmtdUNFbbvdUqRm\n53FW22P9RlWkhpnyggKlO2pQJ3A4k/7kYuVSYAQS+JiuLPjZE1zwuQs1uaVlI6a0\ny88u2FAm5V1EppfqT/rqqHmyJOH0tBsY20Chke7+fFX1BnQ8kv9amSnPsQ59AYr9\nvzQUAU4TgnJKKuQfEnxr4JVktN4sEndrNOPehftMkqSYkHOmiZoCJoZTCRTd2btv\nQncISw81AgMBAAECggEACHlpSOuEP/JFPQTUnjDddWiuNZPGCkOwgf+NEBVC17Kd\nELf9z3TFlHy8GMvdb7drS//bHG9nhv59moSaezChIH2UjroZmwm+9+yMrbMLK/5a\nxHNAyLNMKj4GKv51ANutGKh8Hkqx3YQJfar23yUJ73M6chR0qXOOfdjpKB5d7q2Z\nbQV1GegJOwzq/tc2QXZqg1YH1LQGAXKo16osbzSSQ87IqcFK2zX5idoek7wgfO1T\nj2gvwwuhEhfVB0hEwk7lbOElcnOHkWyEakP6P8S8SDEfxKbFdry5/dH5Qf3Y7PBD\n8aE+AYYOyKuyAFypkCdtBY/UTVrRsLGLs6g8ZQjgwQKBgQD8IBRq5PRvn9meMu+Z\nzmv4+6UgkhKcOq0Rd+i5MCKDyrQ3n7AgWTE5ZEOCWvMTXsz+8AbwdRjKK2OAhgFi\nJXC8r0VXY61MxGS3NvxelrJpuc2o3qNvYgOT/+K8C6WLPYlR4GIpcBM62Khk/qAT\npklVgtOX4tmlj8nFjGF7T5pLdQKBgQC8kBXFSnnJBCWLYi0euayFg120mrgz2RsS\nKRcYTWRmgt2b7cVmgqklXbSldeEzYmwCG/8XtNqMjE/8mAw1MBD/rvdt7lpXbcZd\neo5Q20sbXsWal/IxHorrJJEbOo/w4scTVRA8ZwnI1FGnvQk6N12MwO+3TUjyjZvZ\nrWIGHs38wQKBgCucQOvcfotwUuwSU29/TR3cKUvg+GcdnyIOY6rksJOrVFDqxkRS\nKTmMJkE+Ch2noD3YttqQ5qDRsHxisYqQf1ej2ZKsIyXMMr+eOzkBSAsRoIk9OXfi\ntEu9TzLHsPLMyhvnfBM+15SuNTKC+J1tffHUl1UGYC9LF9Ob3KC/vCihAoGBAJwG\nTT1WhrcCK17N+a+2yz4emObcLxcXygKY5XdCcpUwK9beQ7yy2OsGQne2toUiJ2UH\nbWhcSYqKf5Tu6wsHnskyKaJY24AEYWLwCdp12gvnu3JT0B88uo4fT8JMDtavjzI7\n7JdOWxZGONqm3H/DWDEjZDc0R+wLqK3RfY665o8BAoGAO8HO42LEUBW8zfxbeXCz\nVx+NfulnPiMzYQuDO5fj+PKSwk4JYgeBjuJileYFm2NQ+A/reIJDXN1bVdnVLGeV\nefav4axIA7V52y0azoV/FWLOGNL7J+wp7pl5bd0gDzY8OXSpKS2pcvUSPODkXzjf\nU2lklC2oirQ1CaAuZsEmcgs=\n-----END PRIVATE KEY-----\n',
      'client_email':
          'firebase-adminsdk-z4h24@learnovia-notifications.iam.gserviceaccount.com',
      'client_id': '115109653578095742984',
      'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
      'token_uri': 'https://oauth2.googleapis.com/token',
      'auth_provider_x509_cert_url':
          'https://www.googleapis.com/oauth2/v1/certs',
      'client_x509_cert_url':
          'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-z4h24%40learnovia-notifications.iam.gserviceaccount.com',
      'universe_domain': 'googleapis.com',
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
    required String userId,
    String? imageUrl,
    required Map<String, dynamic> dataToNavigateToRoom,
  }) async {
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/learnovia-notifications/messages:send';
    final Map<String, dynamic> data = {
      'message': {
        'topic': '',
        'notification': {'title': title, 'body': body, 'image': imageUrl ?? ''},
        'data': dataToNavigateToRoom,
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
          userId: userId,
          imageUrl: imageUrl,
          dataToNavigateToRoom: dataToNavigateToRoom,
        );
      }
    }
  }

  static subscribeToTopic() {
    _instance.subscribeToTopic('all');
    _instance.subscribeToTopic(CacheService.uid ?? 'all');
  }

  static Future<void> deleteNotificationToken() async {
    await _instance.deleteToken().catchError((onError) {});
  }

  static Future<void> unSubscribeFromTopic() async {
    _instance.unsubscribeFromTopic('all');
    _instance.unsubscribeFromTopic(CacheService.uid ?? 'all');
  }

  static logEvent(String eventName, Map<String, Object> eventParams) {
    _analyticsInstance.logEvent(name: eventName, parameters: eventParams);
  }
}
