import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import '../../config/app_config.dart';
import '../functions/print_with_color.dart';
import 'call_kit_service.dart';

class AppFirebaseNotification {
  // ==================== Instances ====================
  static final _instance = FirebaseMessaging.instance;
  static final _analyticsInstance = FirebaseAnalytics.instance;
  static final _db = FirebaseFirestore.instance;

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

  static void logEvent(String eventName, Map<String, Object> eventParams) {
    _analyticsInstance.logEvent(name: eventName, parameters: eventParams);
  }

  // ==================== Initialization ====================
  static Future<void> initNotification(
      BuildContext context, HomeCubit homeCubit) async {
    printWithColor('🔄 [FCM_INIT] Starting FCM notification initialization');

    await notificationPermission;
    printWithColor('✅ [FCM_INIT] Notification permission granted');

    // Request full screen intent permission for Android 14+
    if (Platform.isAndroid) {
      printWithColor('🤖 [FCM_INIT] Android platform detected, requesting full screen intent permission');
      await CallKitPermissionHelper.ensureFullScreenIntentPermission();
    }

    if (context.mounted) {
      printWithColor('📱 [FCM_INIT] Context mounted, setting up notification handlers');

      // Setup notification handlers
      whileAppOpenHandleNotification(homeCubit, context);
      whileAppCloseHandleNotification(context);
      whileAppOnBackgroundHandleNotification(context);
      //deleteData();
      // Setup CallKit listeners
      initCallKitListeners(context,homeCubit);

      // Enable analytics
      _analyticsInstance.setAnalyticsCollectionEnabled(true);

      // Platform specific setup
      if (Platform.isAndroid) {
        androidNotificationChannelForPopUpNotification();
      } else {
        _instance.getAPNSToken();
      }

      printWithColor('✅ [FCM_INIT] FCM notification initialization completed');
    } else {
      printWithColor('⚠️ [FCM_INIT] Context not mounted, skipping FCM setup');
    }
  }

  // ==================== Permissions ====================
  static Future<void> get notificationPermission async {
    printWithColor('🔐 [FCM_PERMISSIONS] Requesting notification permission');
    await _instance.requestPermission(announcement: true);
    printWithColor('✅ [FCM_PERMISSIONS] Notification permission requested');

    // Check FCM token
    final token = await _instance.getToken();
    printWithColor('🔑 [FCM_TOKEN] FCM Token: ${token?.substring(0, 20)}...');
  }

  // ==================== Notification Handlers ====================

  /// Handle notifications when app is in foreground
  static void whileAppOpenHandleNotification(
      HomeCubit homeCubit, BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      printWithColor('📬 [FOREGROUND] Notification received');
      printWithColor('📬 [FOREGROUND] Title: ${message.notification?.title}');
      printWithColor('📬 [FOREGROUND] Body: ${message.notification?.body}');
      printWithColor('📬 [FOREGROUND] Data: ${message.data}');

      // Update notification count
      if (message.notification != null) {
        homeCubit.getNotificationsCount();
      }

      // Handle incoming call
      if (message.data['type'] == 'incoming_call') {
        printWithColor('📞 [FOREGROUND] Incoming call notification detected');
        if (AppRouteObserver.currentRouteName != AppRoutes.teacherCallScreen) {
          printWithColor('📞 [FOREGROUND] Not in call screen, showing incoming call dialog');
          if (context.mounted) {
            _showIncomingCall(message.data, context);
          } else {
            printWithColor('⚠️ [FOREGROUND] Context not mounted, cannot show incoming call');
          }
        } else {
          printWithColor('📞 [FOREGROUND] Already in call screen, ignoring incoming call notification');
        }
      } else {
        printWithColor('📬 [FOREGROUND] Regular notification (not incoming call)');
      }
    });
  }

  /// Handle notifications when app is closed
  static Future<void> whileAppCloseHandleNotification(
      BuildContext context) async {
    await _instance.getInitialMessage().then((message) {
      if (message != null) {
        printWithColor('📬 [TERMINATED] App opened from terminated state');
        printWithColor('📬 [TERMINATED] Title: ${message.notification?.title}');
        printWithColor('📬 [TERMINATED] Body: ${message.notification?.body}');
        printWithColor('📬 [TERMINATED] Data: ${message.data}');

        if (context.mounted) {
          if (message.data['type'] == 'incoming_call') {
            // Call was already handled by background handler
            printWithColor('🔔 [TERMINATED] CallKit already shown for incoming call');
          } else {
            printWithColor('📬 [TERMINATED] Handling regular notification');
            onTabNotification(message, context);
          }
        } else {
          printWithColor('⚠️ [TERMINATED] Context not mounted');
        }
      } else {
        printWithColor('📬 [TERMINATED] No initial message');
      }
    });
  }

  /// Handle notifications when app is in background
  static Future<void> whileAppOnBackgroundHandleNotification(
      BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        printWithColor('📬 [BACKGROUND] App opened from background');
        printWithColor('📬 [BACKGROUND] Title: ${message.notification?.title}');
        printWithColor('📬 [BACKGROUND] Body: ${message.notification?.body}');
        printWithColor('📬 [BACKGROUND] Data: ${message.data}');

        if (context.mounted) {
          if (message.data['type'] == 'incoming_call') {
            // Call was already handled by CallKit
            printWithColor('🔔 [BACKGROUND] CallKit already handled incoming call');
          } else {
            printWithColor('📬 [BACKGROUND] Handling regular notification');
            onTabNotification(message, context);
          }
        } else {
          printWithColor('⚠️ [BACKGROUND] Context not mounted');
        }
      } else {
        printWithColor('📬 [BACKGROUND] Empty data in background notification');
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

  // ==================== Push Notifications ====================

  /// Send regular push notification
  static Future<void> pushNotification({
    required String title,
    required String body,
    String? imageUrl,
    required Map<String, dynamic> dataInNotification,
    required String topic,
  }) async {
    try {
      final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (authToken == null) {
        printWithColor('❌ Error: User not authenticated');
        return;
      }

      final response = await _dio.post(
        '${AppConfig.signalingServerUrl}/api/send-notification',
        data: {
          'topic': topic,
          'title': title,
          'body': body,
          'data': {
            ...dataInNotification,
            if (imageUrl != null) 'image': imageUrl,
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        printWithColor('✅ Push notification sent successfully');
      } else {
        printWithColor('❌ Push notification error: ${response.data}');
      }
    } on DioException catch (e) {
      printWithColor('❌ Push notification error: ${e.response?.data ?? e.message}');
    } catch (e) {
      printWithColor('❌ Push notification error: $e');
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
    printWithColor('📞 [CALL_NOTIFICATION] Starting to send incoming call notification');
    printWithColor('📞 [CALL_NOTIFICATION] CallId: $callId, Caller: $callerName, Teacher: $teacherUid, Student: $studentUid');

    try {
      final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (authToken == null) {
        printWithColor('❌ [CALL_NOTIFICATION] Error: User not authenticated - cannot send notification');
        return;
      }

      printWithColor('✅ [CALL_NOTIFICATION] Auth token obtained successfully');

      // Validate and get proper image URL
      final validPhoto = ImageHelper.getValidImageUrl(callerPhoto);
      printWithColor('🖼️ [CALL_NOTIFICATION] Caller photo validated: $validPhoto');

      final signalingUrl = '${AppConfig.signalingServerUrl}/api/send-notification';
      printWithColor('🌐 [CALL_NOTIFICATION] Sending to signaling server: $signalingUrl');

      final requestData = {
        'topic': teacherUid,
        'title': 'Incoming Call',
        'body': '$callerName is calling you',
        'data': {
          'type': 'incoming_call',
          'callId': callId,
          'callerName': callerName,
          'callerPhoto': validPhoto,
          'teacherUid': teacherUid,
          'studentUid': studentUid,
        },
      };

      printWithColor('📤 [CALL_NOTIFICATION] Request data: ${requestData.toString()}');

      final response = await _dio.post(
        signalingUrl,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authToken.substring(0, 20)}...', // Log partial token for security
            'Content-Type': 'application/json',
          },
        ),
      );

      printWithColor('📡 [CALL_NOTIFICATION] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        printWithColor('✅ [CALL_NOTIFICATION] Incoming call notification sent successfully to teacher: $teacherUid');
      } else {
        printWithColor('❌ [CALL_NOTIFICATION] Call notification failed with status ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      printWithColor('❌ [CALL_NOTIFICATION] DioException: ${e.message}');
      printWithColor('❌ [CALL_NOTIFICATION] Response data: ${e.response?.data}');
      printWithColor('❌ [CALL_NOTIFICATION] Response status: ${e.response?.statusCode}');
    } catch (e) {
      printWithColor('❌ [CALL_NOTIFICATION] Unexpected error: $e');
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
  static void initCallKitListeners(BuildContext context,HomeCubit homeCubit) {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;

      printWithColor('🔔 CallKit Event: ${event.event}');

      switch (event.event) {
        case Event.actionCallIncoming:
          if(event.body != null){
            if(homeCubit.isDialogShowing && context.mounted){
              Navigator.pop(context);
              homeCubit.isDialogShowing = false;
            }
            if(AppRouteObserver.currentRouteName == AppRoutes.teacherCallScreen) {
             _handleCallDecline(event.body);
            }
          }
          break;
        case Event.actionCallAccept:
          if (context.mounted) {
            _handleCallAccept(event.body, context);
          }
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
      await _db.collection('calls').doc(callId).update({
        'status': 'ended',
        'endedTime': FieldValue.serverTimestamp(),
      });
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

  static void subscribeToTopic(String role) {
    printWithColor('📡 [TOPIC_SUBSCRIPTION] Starting topic subscription for role: $role');

    final uid = CacheService.uid ?? 'all';
    printWithColor('📡 [TOPIC_SUBSCRIPTION] User UID: $uid');

    try {
      _instance.subscribeToTopic('all');
      printWithColor('✅ [TOPIC_SUBSCRIPTION] Subscribed to topic: all');

      _instance.subscribeToTopic(role);
      printWithColor('✅ [TOPIC_SUBSCRIPTION] Subscribed to topic: $role');

      _instance.subscribeToTopic(uid);
      printWithColor('✅ [TOPIC_SUBSCRIPTION] Subscribed to topic: $uid');

      printWithColor('🎉 [TOPIC_SUBSCRIPTION] Successfully subscribed to all topics');
    } catch (e) {
      printWithColor('❌ [TOPIC_SUBSCRIPTION] Error subscribing to topics: $e');
    }
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

  /*static void deleteData(){
    _db.collection("calls").get().then((value){
      // count documents that duration is less than or equal 1 from difference between endedTime and acceptedTime
      int count = 0;
      for(var doc in value.docs){
        if(doc.data().containsKey("endedTime") && doc.data().containsKey("acceptedTime")){
          Timestamp endedTime = doc.data()["endedTime"];
          Timestamp answeredTime = doc.data()["acceptedTime"];
          Duration difference = endedTime.toDate().difference(answeredTime.toDate());
          if(difference.inMinutes <= 1){
            _db.collection("calls").doc(doc.id).delete();
            //print('🗑️ Deleted call document: ${doc.id}');
          }
        }
      }
    });
  }*/
}