import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'core/utilities/services/internet_connectivity_service.dart';
import 'core/utilities/services/call_kit_service.dart';
import 'core/utilities/services/call_state_service.dart';
import 'core/utilities/services/local_notifications_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔄 [BACKGROUND_HANDLER] Background message handler started');

  // Initialize Firebase for background isolate
  if (Firebase.apps.isEmpty) {
    debugPrint('🔄 [BACKGROUND_HANDLER] Initializing Firebase in background isolate');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('✅ [BACKGROUND_HANDLER] Firebase initialized successfully');
  }

  debugPrint('📬 [BACKGROUND_HANDLER] Message received:');
  debugPrint('📬 [BACKGROUND_HANDLER] Title: ${message.notification?.title}');
  debugPrint('📬 [BACKGROUND_HANDLER] Body: ${message.notification?.body}');
  debugPrint('📬 [BACKGROUND_HANDLER] Data: ${message.data}');

  SecureLogger.firebase(
    'Background message received',
    details: 'Type: ${message.data['type']}',
    tag: 'FCM',
  );

  // Handle incoming call in background
  if (message.data['type'] == 'incoming_call') {
    debugPrint('📞 [BACKGROUND_HANDLER] Incoming call detected, showing CallKit');
    await _showBackgroundIncomingCall(message.data);
  } else {
    debugPrint('📬 [BACKGROUND_HANDLER] Not an incoming call notification');
  }
}

/// Show CallKit incoming call from background
Future<void> _showBackgroundIncomingCall(Map<String, dynamic> data) async {
  debugPrint('🔔 [BACKGROUND_CALLKIT] Starting to show CallKit incoming call');

  final callId = data['callId'] ?? '';
  final callerName = data['callerName'] ?? 'Unknown';
  final callerPhoto = data['callerPhoto'];

  debugPrint('🔔 [BACKGROUND_CALLKIT] CallId: $callId, Caller: $callerName, Photo: $callerPhoto');

  SecureLogger.firebase('Incoming call notification', tag: 'CallKit');

  // Check if there are already active calls
  try {
    final activeCalls = await FlutterCallkitIncoming.activeCalls();
    if (activeCalls.isNotEmpty) {
      debugPrint('🔔 [BACKGROUND_CALLKIT] Active calls detected: ${activeCalls.length}, ignoring new call');
      return;
    }
    // Also check global call state
    if (CallStateService().isCurrentlyInCall) {
      debugPrint('🔔 [BACKGROUND_CALLKIT] User already in call according to global state, ignoring new call');
      return;
    }
  } catch (e) {
    debugPrint('❌ [BACKGROUND_CALLKIT] Error checking active calls: $e');
    // Continue showing the call despite error
  }

  // Validate image URL
  final validPhoto = ImageHelper.getValidImageUrl(callerPhoto);
  debugPrint('🔔 [BACKGROUND_CALLKIT] Validated photo URL: $validPhoto');

  // Build CallKit params
  debugPrint('🔔 [BACKGROUND_CALLKIT] Building CallKit parameters');
  final params = CallKitParamsBuilder.build(
    callId: callId,
    callerName: callerName,
    callerPhoto: validPhoto,
    extraData: data,
  );

  debugPrint('🔔 [BACKGROUND_CALLKIT] CallKit params built successfully');

  // Show CallKit incoming call
  debugPrint('🔔 [BACKGROUND_CALLKIT] Showing CallKit incoming call...');
  try {
    await FlutterCallkitIncoming.showCallkitIncoming(params);
    debugPrint('✅ [BACKGROUND_CALLKIT] CallKit incoming call shown successfully');
  } catch (e) {
    debugPrint('❌ [BACKGROUND_CALLKIT] Error showing CallKit: $e');
  }
}

/// Verify Firebase Auth state and clear cache if invalid
Future<void> _verifyAuthState() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      // No user signed in, clear any cached auth data
      debugPrint('🔐 [AUTH_VERIFY] No current user, clearing cache');
      await SecureCacheService.clearAll();
      return;
    }

    // Check internet connectivity before attempting token validation
    final connectivityService = InternetConnectivityService();
    final hasConnection = await connectivityService.hasInternetConnection();
    
    if (!hasConnection) {
      // Offline - allow cached session to continue
      debugPrint('🔐 [AUTH_VERIFY] Offline - skipping token validation, allowing cached session');
      return;
    }

    // Online - verify token is still valid by forcing refresh
    debugPrint('🔐 [AUTH_VERIFY] Online - verifying token for user: ${currentUser.uid}');
    
    // Add timeout to prevent hanging on slow networks
    try {
      await currentUser.getIdToken(true).timeout(const Duration(seconds: 10));
      debugPrint('✅ [AUTH_VERIFY] Token valid, user authenticated');
    } on TimeoutException {
      // Network too slow, treat as validation failure to be safe
      debugPrint('⏰ [AUTH_VERIFY] Token validation timed out, signing out for security');
      throw Exception('Token validation timeout');
    }
  } catch (e) {
    // Token invalid or refresh failed, sign out and clear cache
    debugPrint('❌ [AUTH_VERIFY] Token invalid, signing out: $e');
    try {
      await FirebaseAuth.instance.signOut();
    } catch (signOutError) {
      debugPrint('⚠️ [AUTH_VERIFY] Error during sign out: $signOutError');
    }
    
    await SecureCacheService.clearAll();
    debugPrint('🧹 [AUTH_VERIFY] Cache cleared');
  }
}

// ==================== Main Function ====================
/// Reset user busy status to false on app start
Future<void> _resetBusyStatusOnStart() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'isBusy': false});
      debugPrint('🔄 [APP_START] Reset busy status to false for user: ${user.uid}');
    } catch (e) {
      debugPrint('❌ [APP_START] Failed to reset busy status: $e');
    }
  } else {
    debugPrint('🔄 [APP_START] No authenticated user, skipping busy status reset');
  }
}

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

    // Verify Firebase Auth state and clear invalid sessions
    await _verifyAuthState();

    // Reset busy status on app start
    await _resetBusyStatusOnStart();

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

    // Enable crash collection (set to true to also collect in debug mode for testing)
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Register FCM background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('✅ [MAIN] FCM background message handler registered');

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