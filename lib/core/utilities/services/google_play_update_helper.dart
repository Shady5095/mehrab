import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../widgets/buttons_widget.dart';
import '../resources/strings.dart';

class UpdateHelper {
  static const String packageName = 'com.mehrab.mehrab_quran';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';

  /// التحقق من وجود تحديث
  static Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      // الحصول على النسخة الحالية من التطبيق
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // جلب النسخة والـ Release Notes من Google Play
      Map<String, String?> storeInfo = await _getPlayStoreInfo();
      String? storeVersion = storeInfo['version'];
      String? releaseNotes = storeInfo['releaseNotes'];

      if (storeVersion == null) {
        return {'hasUpdate': false, 'releaseNotes': null};
      }

      // مقارنة النسخ
      bool hasUpdate = _isUpdateAvailable(currentVersion, storeVersion);

      return {
        'hasUpdate': hasUpdate,
        'releaseNotes': releaseNotes,
        'newVersion': storeVersion,
        'currentVersion': currentVersion,
      };
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return {'hasUpdate': false, 'releaseNotes': null};
    }
  }

  /// جلب النسخة والـ Release Notes من Google Play
  static Future<Map<String, String?>> _getPlayStoreInfo() async {
    try {
      final response = await http.get(
        Uri.parse(playStoreUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        String? version;
        String? releaseNotes;

        // استخراج النسخة من meta tags أو من الصفحة
        var softwareVersion = document.querySelector('meta[itemprop="softwareVersion"]');
        if (softwareVersion != null) {
          version = softwareVersion.attributes['content'];
        }

        // محاولة استخراج النسخة من الـ scripts إذا لم تنجح الطريقة الأولى
        if (version == null) {
          var scripts = document.getElementsByTagName('script');
          for (var script in scripts) {
            String content = script.text;
            if (content.contains('[[["')) {
              RegExp versionRegExp = RegExp(r'\[\[\["(\d+\.\d+\.?\d*)"\]\]');
              var match = versionRegExp.firstMatch(content);
              if (match != null) {
                version = match.group(1);
                break;
              }
            }
          }
        }

        // استخراج Release Notes من HTML
        // الطريقة 1: البحث في div معين
        var updateInfoDiv = document.querySelector('div[itemprop="description"]');
        if (updateInfoDiv != null) {
          releaseNotes = updateInfoDiv.text.trim();
        }

        // الطريقة 2: البحث في الـ scripts
        if ((releaseNotes == null || releaseNotes.isEmpty)) {
          var scripts = document.getElementsByTagName('script');
          for (var script in scripts) {
            String content = script.text;

            // البحث عن patterns مختلفة
            List<RegExp> patterns = [
              RegExp(r'recentChangesHTML["\]]+:\s*["\[]([^"\\]*(?:\\.[^"\\]*)*)["\\]', multiLine: true),
              RegExp(r'"What.{0,5}s new[^[]*\[\[\[["\\]+([^"\\]*(?:\\.[^"\\]*)*)["\\]', multiLine: true, dotAll: true),
              RegExp(r'What.s new</.*?>\s*<[^>]*>([^<]+)', multiLine: true),
            ];

            for (var pattern in patterns) {
              var match = pattern.firstMatch(content);
              if (match != null && match.group(1) != null) {
                releaseNotes = match.group(1)!
                    .replaceAll(r'\n', '\n')
                    .replaceAll(r'\\n', '\n')
                    .replaceAll(r'\u003c', '<')
                    .replaceAll(r'\u003e', '>')
                    .replaceAll(r'\"', '"')
                    .replaceAll(r'\\', '')
                    .trim();

                if (releaseNotes.isNotEmpty && releaseNotes.length > 10) {
                  break;
                }
              }
            }

            if (releaseNotes != null && releaseNotes.isNotEmpty) break;
          }
        }

        // تنظيف Release Notes
        if (releaseNotes != null && releaseNotes.isNotEmpty) {
          releaseNotes = releaseNotes
              .replaceAll(RegExp(r'<[^>]*>'), '') // إزالة HTML tags
              .replaceAll(RegExp(r'\s+'), ' ') // تقليل المسافات الزائدة
              .trim();

          // التحقق من أن النص معقول
          if (releaseNotes.length < 5) {
            releaseNotes = null;
          }
        }

        return {'version': version, 'releaseNotes': releaseNotes};
      }
      return {'version': null, 'releaseNotes': null};
    } catch (e) {
      debugPrint('Error fetching store info: $e');
      return {'version': null, 'releaseNotes': null};
    }
  }

  /// مقارنة النسخ
  static bool _isUpdateAvailable(String current, String store) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> storeParts = store.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (storeParts[i] > currentParts[i]) return true;
      if (storeParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  /// إظهار Dialog التحديث الإجباري
  static void showUpdateDialog(BuildContext context, {String? releaseNotes, String? newVersion}) {
    showDialog(
      context: context,
      barrierDismissible: false, // لا يمكن إغلاقه بالضغط خارجه
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: MyAlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image(
                      image: const AssetImage('assets/images/update.png'),
                      height: 65.sp,
                      width: 65.sp,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      AppStrings.newUpdateAvailable.tr(context),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                    Text(
                      AppStrings.whatIsNew.tr(context),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        releaseNotes,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    const Text(
                      'نسخة جديدة من التطبيق متوفرة الآن!\nيرجى التحديث للاستمرار في الاستخدام',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'التحديث مطلوب للاستمرار',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ButtonWidget(
                onPressed: _launchPlayStore,
                label: AppStrings.downloadNow.tr(context),
                height: 32,
                width: 30.wR,
              ),
            ],
          ),
        );
      },
    );
  }

  /// فتح صفحة Google Play
  static Future<void> _launchPlayStore() async {
    final Uri url = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// التحقق التلقائي عند بدء التطبيق
  static Future<void> checkAndShowUpdate(BuildContext context) async {
    Map<String, dynamic> updateInfo = await checkForUpdate();
    bool hasUpdate = updateInfo['hasUpdate'] ?? false;

    if (hasUpdate && context.mounted) {
      showUpdateDialog(
        context,
        releaseNotes: updateInfo['releaseNotes'],
        newVersion: updateInfo['newVersion'],
      );
    }
  }
}