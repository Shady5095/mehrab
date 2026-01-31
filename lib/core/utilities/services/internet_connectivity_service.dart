import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../resources/strings.dart';

class InternetConnectivityService {
  static final InternetConnectivityService _instance =
      InternetConnectivityService._internal();

  factory InternetConnectivityService() => _instance;

  InternetConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
    StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOffline = false;

  void init(BuildContext context) {
    _subscription??= _connectivity.onConnectivityChanged.listen((result) {
      if (!context.mounted) return;
      _handleConnectivityChange(context, result);
    });

  }

  void _handleConnectivityChange(
    BuildContext context,
    List<ConnectivityResult> result,
  ) {
    final isCurrentlyOffline = result.first == ConnectivityResult.none;

    if (isCurrentlyOffline != _isOffline) {
      _isOffline = isCurrentlyOffline;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isCurrentlyOffline ? null : Colors.green,
          content: Text(
            isCurrentlyOffline
                ? AppStrings.checkConnection
                : AppStrings.youAreOnline,
          ),
          dismissDirection:  isCurrentlyOffline
              ? DismissDirection.none
              : null,
          duration:
              isCurrentlyOffline
                  ? const Duration(days: 1)
                  : const Duration(seconds: 2),
        ),
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;

  }

  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && result.first != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }
}
