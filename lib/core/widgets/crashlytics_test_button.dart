import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utilities/services/crashlytics_service.dart';

/// Test button for Firebase Crashlytics
/// Only visible in debug mode
///
/// Usage: Add this widget to any screen during development to test crashes
/// Remove before production release or it will be hidden automatically
class CrashlyticsTestButton extends StatelessWidget {
  const CrashlyticsTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 80,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Test non-fatal exception
          FloatingActionButton(
            heroTag: 'test_exception',
            mini: true,
            backgroundColor: Colors.orange,
            onPressed: () async {
              await CrashlyticsService.testException();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test exception sent to Crashlytics'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Icon(Icons.warning, size: 20),
          ),
          const SizedBox(height: 8),
          // Test fatal crash
          FloatingActionButton(
            heroTag: 'test_crash',
            mini: true,
            backgroundColor: Colors.red,
            onPressed: () async {
              // Show warning dialog
              final shouldCrash = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('⚠️ Test Crash'),
                  content: const Text(
                    'This will force the app to crash.\n\n'
                    'The crash report will be sent to Firebase Crashlytics.\n\n'
                    'Are you sure?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Crash App',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldCrash == true) {
                CrashlyticsService.testCrash();
              }
            },
            child: const Icon(Icons.bug_report, size: 20),
          ),
        ],
      ),
    );
  }
}

/// Alternative: Simple text button version
class CrashlyticsTestTextButton extends StatelessWidget {
  const CrashlyticsTestTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: () async {
        await CrashlyticsService.testException();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test exception sent to Crashlytics'),
            ),
          );
        }
      },
      child: const Text('Test Crashlytics'),
    );
  }
}
