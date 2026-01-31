import 'package:flutter/foundation.dart';

/// Service to track the global call state across the app
class CallStateService {
  static final CallStateService _instance = CallStateService._internal();
  factory CallStateService() => _instance;
  CallStateService._internal();

  final ValueNotifier<bool> _isInCall = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isInCall => _isInCall;

  String? _currentCallId;
  String? get currentCallId => _currentCallId;

  /// Set the user as in a call
  void setInCall(String callId) {
    _currentCallId = callId;
    _isInCall.value = true;
    debugPrint('📞 [CALL_STATE] User set to in call: $callId');
  }

  /// Set the user as not in a call
  void setNotInCall() {
    _currentCallId = null;
    _isInCall.value = false;
    debugPrint('📞 [CALL_STATE] User set to not in call');
  }

  /// Check if user is currently in a call
  bool get isCurrentlyInCall => _isInCall.value;

  /// Get current call ID if in call
  String? getCurrentCallId() => _currentCallId;
}