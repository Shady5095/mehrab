# Secure Logging Migration Guide

## Overview

This guide explains how to migrate from `debugPrint()` and `print()` to the secure `SecureLogger` utility to prevent sensitive information leakage.

**Security Issue:** CWE-532 (Insertion of Sensitive Information into Log File)
**Current Status:** 191 log statements across 24 files need review

---

## Why Secure Logging?

### Problems with Current Logging:

1. **Sensitive Data Exposure**
   - Logs are visible in Android Logcat / iOS Console
   - Logs may be included in crash reports
   - Logs can be extracted from device backups
   - Production logs may contain user data (GDPR violation)

2. **Current Issues in Codebase**
   ```dart
   debugPrint('🔔 Background message received: ${message.messageId}');
   debugPrint('📞 Showing background incoming call from: $callerName');
   debugPrint('✅ App initialized successfully');
   ```

3. **Examples of Sensitive Data Found**
   - User names in call notifications
   - Message IDs
   - Potentially authentication tokens
   - User identifiers

---

## Migration Steps

### Step 1: Import SecureLogger

Replace:
```dart
import 'package:flutter/foundation.dart';
```

With:
```dart
import 'package:mehrab/core/utilities/functions/secure_logger.dart';
```

### Step 2: Replace debugPrint Calls

#### General Information (Safe)
**Before:**
```dart
debugPrint('✅ App initialized successfully');
```

**After:**
```dart
SecureLogger.info('App initialized successfully', tag: 'App');
```

#### Error Logging
**Before:**
```dart
debugPrint('Error: $error');
```

**After:**
```dart
SecureLogger.error(
  'Failed to load data',
  tag: 'DataLoader',
  error: error,
  stackTrace: stackTrace,
);
```

#### Network Requests
**Before:**
```dart
debugPrint('POST /api/users - Status: 200');
```

**After:**
```dart
SecureLogger.network(
  method: 'POST',
  url: '/api/users',
  statusCode: 200,
  tag: 'API',
);
```

#### WebRTC Events
**Before:**
```dart
debugPrint('WebRTC: Call connected');
```

**After:**
```dart
SecureLogger.webrtc('Call connected', tag: 'CallService');
```

#### Firebase Events
**Before:**
```dart
debugPrint('🔔 Background message received: ${message.messageId}');
```

**After:**
```dart
SecureLogger.firebase(
  'Background message received',
  details: 'Message type: ${message.data['type']}',
  tag: 'FCM',
);
// Note: messageId removed as it could be sensitive
```

#### Sensitive Data (Development Only)
**Before:**
```dart
debugPrint('Token: $token');
debugPrint('User email: $email');
```

**After:**
```dart
// ⚠️ NEVER do this! But if you must for debugging:
SecureLogger.sensitive('Token retrieved: ${token?.substring(0, 5)}...');
// Better: Don't log tokens at all!

// For user identification in development:
SecureLogger.log('User authenticated', tag: 'Auth');
// Don't log the actual email!
```

---

## Migration Priority

### High Priority (Contains Sensitive Data)

1. **Authentication Files**
   - `lib/features/authentication/manager/login_screen_cubit/login_screen_cubit.dart`
   - `lib/features/authentication/manager/register_screen_cubit/register_cubit.dart`

2. **API/Network Files**
   - `lib/core/utilities/services/api_service.dart`
   - `lib/core/utilities/services/dio_interceptor.dart`

3. **WebRTC/Calls**
   - `lib/core/utilities/services/webrtc_call_service.dart`
   - `lib/core/utilities/services/socket_service.dart`
   - `lib/core/utilities/services/call_kit_service.dart`

4. **Firebase**
   - `lib/core/utilities/services/firebase_notification.dart`
   - `lib/main.dart`

### Medium Priority (Potentially Sensitive)

5. **Call Management**
   - `lib/features/teacher_call/presentation/manager/teacher_call_cubit/teacher_call_cubit.dart`
   - `lib/features/teacher_call/presentation/manager/student_call_cubit/student_call_cubit.dart`

6. **Notifications**
   - `lib/features/notifications/presentation/widgets/notification_list.dart`

### Low Priority (General Logging)

7. **UI Components**
   - Various widget files
   - Utility functions

---

## What NOT to Log (Ever!)

### Never Log These in Production:

- ❌ Authentication tokens (Bearer tokens, refresh tokens)
- ❌ Passwords (even hashed!)
- ❌ API keys or secrets
- ❌ Session IDs
- ❌ User emails (use user ID instead)
- ❌ Phone numbers
- ❌ Personal Identifiable Information (PII)
- ❌ Payment information
- ❌ Private user data
- ❌ Firebase UIDs in a way that could identify users
- ❌ Full error stack traces in production

### Safe to Log:

- ✅ Generic event names ("User logged in", "Data loaded")
- ✅ Non-sensitive state changes
- ✅ Public configuration values
- ✅ Feature flags
- ✅ App version info
- ✅ Anonymous analytics events

---

## Examples

### Example 1: Background Message Handler

**Before:**
```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message received: ${message.messageId}');

  if (message.data['type'] == 'incoming_call') {
    debugPrint('📞 Showing background incoming call from: ${message.data['callerName']}');
    await _showBackgroundIncomingCall(message.data);
  }
}
```

**After:**
```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  SecureLogger.firebase(
    'Background message received',
    details: 'Type: ${message.data['type']}',
    tag: 'FCM',
  );

  if (message.data['type'] == 'incoming_call') {
    SecureLogger.firebase('Incoming call notification', tag: 'FCM');
    await _showBackgroundIncomingCall(message.data);
  }
}
```

### Example 2: Authentication

**Before:**
```dart
Future<void> signInWithEmailAndPassword(BuildContext context) async {
  emit(LoginWaitingState());
  try {
    final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    debugPrint('User signed in: ${user.user?.email}');
    emit(LoginSuccessState());
  } catch (e) {
    debugPrint('Login error: $e');
    emit(LoginErrorState(e.toString()));
  }
}
```

**After:**
```dart
Future<void> signInWithEmailAndPassword(BuildContext context) async {
  emit(LoginWaitingState());
  try {
    final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    SecureLogger.info('User signed in successfully', tag: 'Auth');
    emit(LoginSuccessState());
  } catch (e) {
    SecureLogger.error(
      'Login failed',
      tag: 'Auth',
      error: e,
    );
    emit(LoginErrorState(e.toString()));
  }
}
```

### Example 3: API Call

**Before:**
```dart
Future<Response> getData({required String endPoint}) async {
  debugPrint('GET $endPoint');
  final response = await _dio.get(endPoint);
  debugPrint('Response: ${response.statusCode}');
  return response;
}
```

**After:**
```dart
Future<Response> getData({required String endPoint}) async {
  final response = await _dio.get(endPoint);
  SecureLogger.network(
    method: 'GET',
    url: endPoint,
    statusCode: response.statusCode,
    tag: 'API',
  );
  return response;
}
```

---

## Automated Migration (Optional)

You can create a simple script to help with migration:

### Find and Replace Patterns:

1. **Simple debugPrint:**
   - Find: `debugPrint\('([^']*)'\);`
   - Replace: `SecureLogger.log('$1');`

2. **debugPrint with variables:**
   - Manual review required for each case

3. **Error logging:**
   - Find: `debugPrint\('Error: \$(.*)'\);`
   - Replace: `SecureLogger.error('Error occurred', error: $1);`

---

## Testing

After migration:

1. **Debug Build:**
   ```bash
   flutter run --debug
   ```
   - Verify logs appear in console
   - Check log formatting

2. **Release Build:**
   ```bash
   flutter run --release
   ```
   - Verify sensitive logs do NOT appear
   - Test in production environment

3. **ProGuard Verification (Android):**
   ```bash
   flutter build apk --release
   # Decompile APK and verify debug code is stripped
   ```

---

## ProGuard Configuration

The following ProGuard rules should keep SecureLogger but strip debug code:

Create `android/app/proguard-rules.pro`:

```pro
# Keep SecureLogger class
-keep class com.mehrab.mehrab_quran.core.utilities.functions.SecureLogger { *; }

# Remove debug logging in release builds
-assumenosideeffects class com.mehrab.mehrab_quran.core.utilities.functions.SecureLogger {
    public static void log(...);
    public static void sensitive(...);
    public static void dump(...);
}

# Keep error logging for crash reports
-keep class com.mehrab.mehrab_quran.core.utilities.functions.SecureLogger {
    public static void error(...);
}
```

---

## Checklist

Before marking migration complete:

- [ ] SecureLogger imported in all files that need it
- [ ] All authentication-related logs reviewed
- [ ] All API/network logs sanitized
- [ ] All Firebase logs reviewed
- [ ] All WebRTC logs reviewed
- [ ] No sensitive data in logs (tokens, emails, passwords)
- [ ] Tested in debug mode
- [ ] Tested in release mode
- [ ] ProGuard rules configured
- [ ] Documentation updated

---

## Rollout Plan

1. **Phase 1: Create SecureLogger** ✅
2. **Phase 2: Migrate high-priority files** (Manual)
3. **Phase 3: Migrate medium-priority files** (Can use scripts)
4. **Phase 4: Migrate low-priority files** (Automated)
5. **Phase 5: Remove old debugPrint imports**
6. **Phase 6: Test and verify**

---

## Additional Resources

- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)
- [CWE-532: Insertion of Sensitive Information into Log File](https://cwe.mitre.org/data/definitions/532.html)
- [Flutter Logging Best Practices](https://docs.flutter.dev/testing/debugging)

---

**Last Updated:** 2026-01-22
**Status:** SecureLogger created, migration pending
