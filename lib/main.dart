import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'app/my_app.dart';
import 'core/utilities/functions/bloc_observer.dart';
import 'core/utilities/functions/dependency_injection.dart';
import 'core/utilities/services/api_service.dart';
import 'core/utilities/services/cache_service.dart';
import 'core/utilities/services/call_kit_service.dart';
import 'core/utilities/services/local_notifications_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('🔔 Background message received: ${message.messageId}');

  // Handle incoming call in background
  if (message.data['type'] == 'incoming_call') {
    await _showBackgroundIncomingCall(message.data);
  }
}

/// Show CallKit incoming call from background
Future<void> _showBackgroundIncomingCall(Map<String, dynamic> data) async {
  final callId = data['callId'] ?? '';
  final callerName = data['callerName'] ?? 'Unknown';
  final callerPhoto = data['callerPhoto'];

  debugPrint('📞 Showing background incoming call from: $callerName');

  // Validate image URL
  final validPhoto = ImageHelper.getValidImageUrl(callerPhoto);

  // Build CallKit params
  final params = CallKitParamsBuilder.build(
    callId: callId,
    callerName: callerName,
    callerPhoto: validPhoto,
    extraData: data,
  );

  // Show CallKit incoming call
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

// ==================== Main Function ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup BLoC observer
  Bloc.observer = MyBlocObserver();

  // Dependency injection
  setup();

  // Handle Android below 8 HTTP connections
  HttpOverrides.global = MyHttpOverrides();

  // Initialize services
  await Future.wait([
    LocalNotificationsService.init(),
    CacheService.init(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  // Register FCM background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  debugPrint('✅ App initialized successfully');

  // Run app
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) {
        return const MyApp();
      },
    ),
  );
}
/// this for setup hive
//
// flutter clean
// flutter pub get
//
// flutter packages pub run build_runner build --delete-conflicting-outputs

///  this for emulator yo run in gpu
// hw.gpu.enabled=no
// hw.gpu.mode=auto
/// ios pod install
// delete ios/Podfile.lock
// delete ios/Pods
// arch -x86_64 pod install
/// build ios
//flutter build ios
// [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: PlatformException(VideoError, Failed to load video: Cannot Open: This media format is not supported.: The operation couldn’t be completed. (OSStatus error -12847.), null, null)