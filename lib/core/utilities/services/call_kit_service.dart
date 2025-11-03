import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import '../functions/print_with_color.dart';

class CallKitService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Update call status when teacher accepts
  static Future<void> acceptCall(String callId) async {
    try {
      await _db.collection('calls').doc(callId).update({
        'status': 'answered',
        'answeredTime': FieldValue.serverTimestamp(),
      });
      printWithColor('✅ Call accepted and Firestore updated');
    } catch (e) {
      printWithColor('❌ Error accepting call: $e');
    }
  }

  /// Update call status when teacher declines
  static Future<void> declineCall(String callId) async {
    try {
      await _db.collection('calls').doc(callId).update({
        'status': 'declined',
        'declinedTime': FieldValue.serverTimestamp(),
      });
      await FlutterCallkitIncoming.endCall(callId);
      printWithColor('✅ Call declined and Firestore updated');
    } catch (e) {
      printWithColor('❌ Error declining call: $e');
    }
  }

  /// Update call status on timeout
  static Future<void> timeoutCall(String callId) async {
    try {
      await _db.collection('calls').doc(callId).update({
        'status': 'missed',
        'missedTime': FieldValue.serverTimestamp(),
      });
      await FlutterCallkitIncoming.endCall(callId);
      printWithColor('✅ Call timeout and Firestore updated');
    } catch (e) {
      printWithColor('❌ Error timing out call: $e');
    }
  }

  /// End call from either side
  static Future<void> endCall(String callId) async {
    try {
      await FlutterCallkitIncoming.endCall(callId);
      printWithColor('✅ CallKit call ended');
    } catch (e) {
      printWithColor('❌ Error ending call: $e');
    }
  }

  /// Check if there are active calls
  static Future<List<dynamic>> getActiveCalls() async {
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      return calls;
    } catch (e) {
      printWithColor('❌ Error getting active calls: $e');
      return [];
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
}


class CallKitParamsBuilder {
  /// Build CallKit parameters with proper image handling
  static CallKitParams build({
    required String callId,
    required String callerName,
    required String? callerPhoto,
    required Map<String, dynamic> extraData,
  }) {
    // Get valid image URL with fallback
    final validAvatarUrl = ImageHelper.getValidImageUrl(callerPhoto);

    // Generate background with gradient effect
    final backgroundColor = '#2ea29d';

    return CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'محراب القرآن',
      avatar: validAvatarUrl,
      handle: 'مكالمة صوتية/مرئية',
      type: 0, // 0 for audio, 1 for video
      duration: 120000, // 2 minutes
      textAccept: 'قبول',
      textDecline: 'رفض',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        subtitle: 'مكالمة فائتة من محراب القرآن',
      ),
      extra: extraData,
      headers: <String, dynamic>{'platform': 'flutter'},
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: true, // Show avatar image
        ringtonePath: 'system_ringtone_default',
        backgroundColor: backgroundColor,
        isImportant: true,
        isShowFullLockedScreen: true,
        //backgroundUrl: validAvatarUrl, // Use avatar as background with blur
        actionColor: '#4CAF50', // Green for accept button
        textColor: '#ffffff',
        logoUrl: "https://ik.imagekit.io/mairddxw6/playstore.png?updatedAt=1761388855784",
        incomingCallNotificationChannelName: 'مكالمات واردة',
        missedCallNotificationChannelName: 'مكالمات فائتة',
        isShowCallID: false,
      ),
      ios: const IOSParams(
        iconName: '',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
  }
}

class ImageHelper {
  /// Get valid image URL or fallback to default
  static String getValidImageUrl(String? imageUrl) {
    // إذا الصورة فاضية أو null، استخدم صورة افتراضية
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://ik.imagekit.io/mairddxw6/chatImagePlaceholder.png?updatedAt=1761386714051';
    }

    // إذا الصورة مش HTTPS، استخدم الافتراضية
    if (!imageUrl.startsWith('https://')) {
      return 'https://ik.imagekit.io/mairddxw6/chatImagePlaceholder.png?updatedAt=1761386714051';
    }

    return imageUrl;
  }

  /// Generate avatar from name
  static String generateAvatarFromName(String name, {String bgColor = '0955fa'}) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=$bgColor&color=fff&size=200&bold=true';
  }
}

class CallKitPermissionHelper {
  /// Check and request full screen intent permission for Android 14+
  static Future<bool> ensureFullScreenIntentPermission() async {
    if (!Platform.isAndroid) {
      return true; // iOS doesn't need this
    }

    try {
      // Check if we can use full screen intent
      final canUse = await FlutterCallkitIncoming.canUseFullScreenIntent();

      debugPrint('📱 Can use full screen intent: $canUse');

      if (canUse == false) {
        // Request permission
        debugPrint('📱 Requesting full screen intent permission...');
        final result = await FlutterCallkitIncoming.requestFullIntentPermission();
        debugPrint('📱 Full screen intent permission result: $result');
        return result ?? false;
      }

      return canUse ?? true;
    } catch (e) {
      debugPrint('❌ Error checking full screen intent permission: $e');
      return false;
    }
  }

  /// Check permission without requesting
  static Future<bool> checkFullScreenIntentPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final canUse = await FlutterCallkitIncoming.canUseFullScreenIntent();
      return canUse ?? false;
    } catch (e) {
      debugPrint('❌ Error checking full screen intent: $e');
      return false;
    }
  }
}