import 'dart:io';

import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppReviewService {
  static const _keyHasReviewed = 'hasReviewed';
  static const _keyLastPromptDate = 'lastPromptDate';
  static const _daysBetweenPrompts = 5;

  /// 🟢 دالة لإظهار التقييم بشكل فوري (عند الضغط مثلاً)
  static Future<void> showReviewNow() async {
    final inAppReview = InAppReview.instance;
    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyHasReviewed, true);
      }
    } catch (e) {
      debugPrint('❌ Error showing in-app review: $e');
    }
  }

  /// 🕓 دالة لإظهار التقييم حسب المدة (كل 5 أيام إذا لم يقيم)
  static Future<void> showReviewPromptIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasReviewed = prefs.getBool(_keyHasReviewed) ?? false;
    final lastPromptMillis = prefs.getInt(_keyLastPromptDate);
    final now = DateTime.now();

    if (hasReviewed) return;

    if (lastPromptMillis != null) {
      final lastPromptDate = DateTime.fromMillisecondsSinceEpoch(lastPromptMillis);
      final diffDays = now.difference(lastPromptDate).inDays;
      if (diffDays < _daysBetweenPrompts) return;
    }

    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      try {
        await inAppReview.requestReview();
        await prefs.setBool(_keyHasReviewed, true);
      } catch (e) {
        debugPrint('❌ Error showing in-app review: $e');
      }
    }

    await prefs.setInt(_keyLastPromptDate, now.millisecondsSinceEpoch);
  }
  static Future<void> openStoreReviewPage() async {
    final String androidPackage = 'com.mehrab.mehrab_quran'; // غيّرها لاسم الباكدج بتاعك
    final String iosAppId = '6753643222'; // غيّرها لـ App ID من App Store Connect

    String url = '';

    if (Platform.isAndroid) {
      // رابط مباشر لتقييم التطبيق في Google Play
      url = 'https://play.google.com/store/apps/details?id=$androidPackage&reviewId=0';
    } else if (Platform.isIOS) {
      // رابط مباشر لتقييم التطبيق في App Store
      url = 'https://apps.apple.com/app/id$iosAppId?action=write-review';
    } else {
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
