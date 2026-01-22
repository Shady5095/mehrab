import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class CallForegroundService {
  static bool _isServiceRunning = false;
  static bool _isSilentMode = false;

  /// Initialize foreground service
  static Future<void> init({bool silentMode = false}) async {
    if (!Platform.isAndroid) return;

    _isSilentMode = silentMode;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'call_foreground_service',
        channelName: 'مكالمة نشطة',
        channelDescription: 'يحافظ على المكالمة نشطة في الخلفية',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        // 🆕 عند المعلم نخفي الإشعار
        visibility: silentMode
            ? NotificationVisibility.VISIBILITY_SECRET
            : NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Start foreground service for active call
  static Future<bool> startCallService({
    required String callerName,
    required String callDuration,
    bool silentMode = false,
  }) async {
    if (!Platform.isAndroid) return false;

    _isSilentMode = silentMode;

    if (_isServiceRunning) {
      if (!silentMode) {
        await updateCallService(
          callerName: callerName,
          callDuration: callDuration,
        );
      }
      return true;
    }

    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    final ServiceRequestResult result =
    await FlutterForegroundTask.startService(
      notificationTitle: silentMode ? '' : 'مكالمة نشطة',
      notificationText: silentMode ? '' : '$callerName • $callDuration',
      callback: startCallback,
    );

    if (result is ServiceRequestSuccess) {
      _isServiceRunning = true;
      debugPrint('✅ Foreground service started ${silentMode ? "(silent mode)" : ""}');
      return true;
    } else {
      debugPrint('❌ Failed to start foreground service: $result');
      return false;
    }
  }

  /// Update notification during call (للطالب فقط)
  static Future<void> updateCallService({
    required String callerName,
    required String callDuration,
  }) async {
    if (!Platform.isAndroid || !_isServiceRunning || _isSilentMode) return;

    await FlutterForegroundTask.updateService(
      notificationTitle: 'مكالمة نشطة',
      notificationText: '$callerName • $callDuration',
    );
  }

  /// Stop foreground service
  static Future<void> stopCallService() async {
    if (!Platform.isAndroid || !_isServiceRunning) return;

    await FlutterForegroundTask.stopService();
    _isServiceRunning = false;
    _isSilentMode = false;
    debugPrint('✅ Foreground service stopped');
  }

  /// Check if service is running
  static bool get isRunning => _isServiceRunning;
}

// Callback for foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(CallTaskHandler());
}

class CallTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('🔄 Foreground task started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Keep service alive - this runs every 5 seconds
    // This is essential to keep audio session active in background
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('🔄 Foreground task destroyed');
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button presses if needed
  }

  @override
  void onNotificationPressed() {
    // Handle notification tap - bring app to foreground
    FlutterForegroundTask.launchApp('/');
  }
}