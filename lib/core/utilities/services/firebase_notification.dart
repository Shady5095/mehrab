import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/core/utilities/services/sensitive_app_constants.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import '../functions/print_with_color.dart';
import '../resources/constants.dart';
import 'call_kit_service.dart';

class AppFirebaseNotification {
  // ==================== Instances ====================
  static final _instance = FirebaseMessaging.instance;
  static final _analyticsInstance = FirebaseAnalytics.instance;
  static final _db = FirebaseFirestore.instance;
  static late String accessToken;

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

  // ==================== Analytics ====================
  static FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analyticsInstance);
  }

  static logEvent(String eventName, Map<String, Object> eventParams) {
    _analyticsInstance.logEvent(name: eventName, parameters: eventParams);
  }

  // ==================== Initialization ====================
  static Future<void> initNotification(
      BuildContext context, HomeCubit homeCubit) async {
    await notificationPermission;

    if (context.mounted) {
      // Setup notification handlers
      whileAppOpenHandleNotification(homeCubit, context);
      whileAppCloseHandleNotification(context);
      whileAppOnBackgroundHandleNotification(context);

      // Setup CallKit listeners
      initCallKitListeners(context);

      // Get access token for FCM
      getAccessToken();

      // Enable analytics
      _analyticsInstance.setAnalyticsCollectionEnabled(true);

      // Platform specific setup
      if (Platform.isAndroid) {
        androidNotificationChannelForPopUpNotification();
      } else {
        _instance.getAPNSToken();
      }
    }
  }

  // ==================== Permissions ====================
  static Future<void> get notificationPermission async {
    await _instance.requestPermission(announcement: true);
  }

  // ==================== Notification Handlers ====================

  /// Handle notifications when app is in foreground
  static void whileAppOpenHandleNotification(
      HomeCubit homeCubit, BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      printWithColor('📬 Foreground notification received');

      // Update notification count
      if (message.notification != null) {
        homeCubit.getNotificationsCount();
      }

      // Handle incoming call
      if (message.data['type'] == 'incoming_call') {
        _showIncomingCall(message.data, context);
      }
    });
  }

  /// Handle notifications when app is closed
  static Future<void> whileAppCloseHandleNotification(
      BuildContext context) async {
    await _instance.getInitialMessage().then((message) {
      if (message != null && context.mounted) {
        printWithColor('📬 App opened from terminated state');

        if (message.data['type'] == 'incoming_call') {
          // Call was already handled by background handler
          printWithColor('🔔 CallKit already shown');
        } else {
          onTabNotification(message, context);
        }
      }
    });
  }

  /// Handle notifications when app is in background
  static Future<void> whileAppOnBackgroundHandleNotification(
      BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty && context.mounted) {
        printWithColor('📬 App opened from background');

        if (message.data['type'] == 'incoming_call') {
          // Call was already handled by CallKit
          printWithColor('🔔 CallKit already handled');
        } else {
          onTabNotification(message, context);
        }
      }
    });
  }

  /// Handle notification tap actions
  static void onTabNotification(
      RemoteMessage? message, BuildContext context) {
    if (message != null) {
      final type = message.data['type'];

      switch (type) {
        case 'notification':
          context.navigateTo(pageName: AppRoutes.notificationsScreen);
          break;
        case 'studentRate':
          context.navigateTo(pageName: AppRoutes.teacherReviewsScreen);
          break;
        case 'studentFavorite':
          context.navigateTo(pageName: AppRoutes.favoriteStudentsScreen);
          break;
        default:
          printWithColor('⚠️ Unknown notification type: $type');
      }
    }
  }

  // ==================== Android Setup ====================
  static Future<void> androidNotificationChannelForPopUpNotification() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ==================== FCM Access Token ====================
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "mehrab-a8e60",
      "private_key_id": "7d0bafe44af019f11fa73ec5b870befb1b5987c5",
      "private_key": SensitiveAppConstants.privateKeyNotifications,
      "client_email":
      "firebase-adminsdk-fbsvc@mehrab-a8e60.iam.gserviceaccount.com",
      "client_id": "117743556891008027326",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
      "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40mehrab-a8e60.iam.gserviceaccount.com",
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

      final auth.AccessCredentials credentials =
      await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );

      client.close();
      accessToken = credentials.accessToken.data;
      printWithColor('✅ FCM Access Token obtained');
      return credentials.accessToken.data;
    } on Exception catch (e) {
      printWithColor('❌ Error getting access token: $e');
      return '';
    }
  }

  // ==================== Push Notifications ====================

  /// Send regular push notification
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
        'notification': {
          'title': title,
          'body': body,
          'image': imageUrl ?? ''
        },
        'data': dataInNotification,
        'android': {
          'notification': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
          'priority': 'high',
        },
        'apns': {
          'payload': {
            'aps': {
              'category': 'FLUTTER_NOTIFICATION_CLICK',
              'content-available': 1,
              'sound': 'default',
            },
          },
        },
      },
    };

    try {
      await _dio.post(fcmUrl, data: data);
      printWithColor('✅ Push notification sent successfully');
    } on DioException catch (e) {
      printWithColor('❌ Push notification error: ${e.response?.data}');

      if (e.response?.statusCode == AppConstants.unauthenticated) {
        await getAccessToken();
        await pushNotification(
          title: title,
          body: body,
          imageUrl: imageUrl,
          dataInNotification: dataInNotification,
          topic: topic,
        );
      }
    }
  }

  /// Send incoming call notification with CallKit
  static Future<void> pushIncomingCallNotification({
    required String callId,
    required String callerName,
    required String callerPhoto,
    required String teacherUid,
    required String studentUid,
  }) async {
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/mehrab-a8e60/messages:send';

    // Validate and get proper image URL
    final validPhoto = ImageHelper.getValidImageUrl(callerPhoto);

    final Map<String, dynamic> data = {
      'message': {
        'topic': teacherUid,
        'data': {
          'type': 'incoming_call',
          'callId': callId,
          'callerName': callerName,
          'callerPhoto': validPhoto,
          'teacherUid': teacherUid,
          'studentUid': studentUid,
        },
        'android': {
          'priority': 'high',
        },
        'apns': {
          'payload': {
            'aps': {
              'content-available': 1,
              'sound': 'default',
            },
          },
        },
      },
    };

    try {
      await _dio.post(fcmUrl, data: data);
      printWithColor('✅ Incoming call notification sent to: $teacherUid');
    } on DioException catch (e) {
      printWithColor('❌ Call notification error: ${e.response?.data}');

      if (e.response?.statusCode == AppConstants.unauthenticated) {
        await getAccessToken();
        await pushIncomingCallNotification(
          callId: callId,
          callerName: callerName,
          callerPhoto: callerPhoto,
          teacherUid: teacherUid,
          studentUid: studentUid,
        );
      }
    }
  }

  // ==================== CallKit Management ====================

  /// Show incoming call screen
  static Future<void> _showIncomingCall(
      Map<String, dynamic> data, BuildContext context) async {
    final callId = data['callId'] ?? '';
    final callerName = data['callerName'] ?? 'Unknown';
    final callerPhoto = data['callerPhoto'];

    printWithColor('📞 Showing incoming call: $callId from $callerName');

    final params = CallKitParamsBuilder.build(
      callId: callId,
      callerName: callerName,
      callerPhoto: callerPhoto,
      extraData: data,
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  /// Initialize CallKit event listeners
  static void initCallKitListeners(BuildContext context) {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;

      printWithColor('🔔 CallKit Event: ${event.event}');

      switch (event.event) {
        case Event.actionCallAccept:
          _handleCallAccept(event.body, context);
          break;

        case Event.actionCallDecline:
          _handleCallDecline(event.body);
          break;

        case Event.actionCallEnded:
          _handleCallEnd(event.body);
          break;

        case Event.actionCallTimeout:
          _handleCallTimeout(event.body);
          break;

        default:
          printWithColor('⚠️ Unhandled CallKit event: ${event.event}');
      }
    });
  }

  /// Handle call accept
  static Future<void> _handleCallAccept(
      Map<String, dynamic>? callData, BuildContext context) async {
    if (callData == null) return;

    final callId = callData['callId'] ?? callData['id'];
    printWithColor('✅ Teacher accepted call: $callId');

    try {
      // Update Firestore
      await _db.collection('calls').doc(callId).update({
        'status': 'answered',
        'answeredTime': FieldValue.serverTimestamp(),
      });

      // Fetch full call data
      final callDoc = await _db.collection('calls').doc(callId).get();

      if (callDoc.exists && context.mounted) {
        final callModel = CallModel.fromJson(callDoc.data()!);

        // Navigate to call screen
        context.navigateTo(
          pageName: AppRoutes.teacherCallScreen,
          arguments: [callModel],
        );
      }
    } catch (e) {
      printWithColor('❌ Error accepting call: $e');
    }
  }

  /// Handle call decline
  static Future<void> _handleCallDecline(
      Map<String, dynamic>? callData) async {
    if (callData == null) return;

    final callId = callData['callId'] ?? callData['id'];
    printWithColor('❌ Teacher declined call: $callId');

    try {
      await _db.collection('calls').doc(callId).update({
        'status': 'declined',
        'declinedTime': FieldValue.serverTimestamp(),
      });

      await FlutterCallkitIncoming.endCall(callId);
    } catch (e) {
      printWithColor('❌ Error declining call: $e');
    }
  }

  /// Handle call end
  static Future<void> _handleCallEnd(Map<String, dynamic>? callData) async {
    if (callData == null) return;

    final callId = callData['callId'] ?? callData['id'];
    printWithColor('🔚 Call ended: $callId');

    try {
      await FlutterCallkitIncoming.endCall(callId);
    } catch (e) {
      printWithColor('❌ Error ending call: $e');
    }
  }

  /// Handle call timeout
  static Future<void> _handleCallTimeout(
      Map<String, dynamic>? callData) async {
    if (callData == null) return;

    final callId = callData['callId'] ?? callData['id'];
    printWithColor('⏱️ Call timeout: $callId');

    try {
      await _db.collection('calls').doc(callId).update({
        'status': 'missed',
        'missedTime': FieldValue.serverTimestamp(),
      });

      await FlutterCallkitIncoming.endCall(callId);
    } catch (e) {
      printWithColor('❌ Error handling timeout: $e');
    }
  }

  /// End specific call
  static Future<void> endCall(String callId) async {
    try {
      await FlutterCallkitIncoming.endCall(callId);
      printWithColor('✅ CallKit call ended: $callId');
    } catch (e) {
      printWithColor('❌ Error ending CallKit call: $e');
    }
  }

  /// End all active calls
  static Future<void> endAllCalls() async {
    try {
      await FlutterCallkitIncoming.endAllCalls();
      printWithColor('✅ All CallKit calls ended');
    } catch (e) {
      printWithColor('❌ Error ending all calls: $e');
    }
  }

  // ==================== Topics Management ====================

  static subscribeToTopic(String role) {
    _instance.subscribeToTopic('all');
    _instance.subscribeToTopic(role);
    _instance.subscribeToTopic(CacheService.uid ?? 'all');
    printWithColor('✅ Subscribed to topics: all, $role, ${CacheService.uid}');
  }

  static Future<void> unSubscribeFromTopic(String role) async {
    _instance.unsubscribeFromTopic('all');
    _instance.unsubscribeFromTopic(role);
    _instance.unsubscribeFromTopic(CacheService.uid ?? 'all');
    printWithColor('✅ Unsubscribed from topics');
  }

  static Future<void> deleteNotificationToken() async {
    await _instance.deleteToken().catchError((onError) {
      printWithColor('❌ Error deleting token: $onError');
    });
  }
}