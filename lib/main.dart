import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'app/my_app.dart';
import 'core/utilities/functions/bloc_observer.dart';
import 'core/utilities/functions/dependency_injection.dart';
import 'core/utilities/functions/secure_logger.dart';
import 'core/utilities/services/cache_service.dart';
import 'core/utilities/services/secure_cache_service.dart';
import 'core/utilities/services/call_kit_service.dart';
import 'core/utilities/services/local_notifications_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background isolate
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  SecureLogger.firebase(
    'Background message received',
    details: 'Type: ${message.data['type']}',
    tag: 'FCM',
  );

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

  SecureLogger.firebase('Incoming call notification', tag: 'CallKit');

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
Future<void> main() async {
  // Run the app within a guarded zone to catch all errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Setup BLoC observer
    Bloc.observer = MyBlocObserver();

    // Dependency injection
    setup();

    // Initialize services
    await Future.wait([
      LocalNotificationsService.init(),
      CacheService.init(),
    ]);

    // Initialize secure cache and migrate sensitive data
    // This must run after CacheService.init() to read old data
    await SecureCacheService.init();

    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize Firebase App Check with Play Integrity (replaces deprecated SafetyNet)
    await FirebaseAppCheck.instance.activate();

    // ========== Configure Firebase Crashlytics ==========

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // Also log to secure logger in debug mode
      if (kDebugMode) {
        SecureLogger.error(
          'Flutter Fatal Error',
          tag: 'Crashlytics',
          error: errorDetails.exception,
        );
      }
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // Also log to secure logger in debug mode
      if (kDebugMode) {
        SecureLogger.error(
          'Async Error',
          tag: 'Crashlytics',
          error: error,
        );
      }
      return true;
    };

    // Enable crash collection in release mode only (optional - can be enabled in debug too)
    // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Register FCM background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    SecureLogger.info('App initialized successfully with Crashlytics', tag: 'App');

    // Run app
    runApp(
      DevicePreview(
        enabled: false,
        builder: (context) {
          return const MyApp();
        },
      ),
    );
  }, (error, stack) {
    // Catch errors that occur outside of the Flutter framework
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    if (kDebugMode) {
      SecureLogger.error(
        'Zone Error',
        tag: 'Crashlytics',
        error: error,
      );
    }
  });
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