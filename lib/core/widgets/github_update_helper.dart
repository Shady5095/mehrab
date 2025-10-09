import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/buttons_widget.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateHelper {
  static const String versionUrl =
      'https://raw.githubusercontent.com/Shady5095/mehrab-apk-download/main/version.json';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      printWithColor("🔍 Checking for updates...");
      final response = await http.get(Uri.parse(versionUrl));

      printWithColor("📡 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final latestVersion = data['latest_version_code'];
        final apkUrl = data['apk_url'];
        final notes = data['release_notes'];
        final bool isRequired = data['is_required'] ?? false;
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        int currentVersion = int.parse(packageInfo.buildNumber);

        printWithColor("📱 Current: $currentVersion | Latest: $latestVersion");
        printWithColor("🔗 APK URL: $apkUrl");

        if (latestVersion > currentVersion) {
          if (!context.mounted) return;
          printWithColor("✅ Update available, showing dialog...");
          _showUpdateDialog(context, apkUrl, notes, isRequired);
        } else {
          printWithColor("✅ App is up to date");
        }
      }
    } catch (e) {
      printWithColor("❌ Error checking update: $e");
    }
  }

  static void _showUpdateDialog(
      BuildContext context,
      String apkUrl,
      String notes,
      bool isRequired,
      ) {
    printWithColor("📋 Showing update dialog...");
    showDialog(
      context: context,
      barrierDismissible: !isRequired,
      builder: (dialogContext) => PopScope(
        canPop: !isRequired,
        child: UpdateDialog(
          notes: notes,
          isRequired: isRequired,
          onUpdatePressed: () {
            printWithColor("🔘 Update button pressed");
            Navigator.pop(dialogContext);
            _downloadAndInstallApk(context, apkUrl, isRequired);
          },
        ),
      ),
    );
  }

  static Future<String> get appDownloadDirectoryPath async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadPath = '${directory.path}/downloads';
        final downloadDir = Directory(downloadPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        printWithColor("📂 Download path: $downloadPath");
        return downloadDir.path;
      }
    }
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<bool> _requestPermissions() async {
    printWithColor("🔐 Requesting permissions...");

    if (Platform.isAndroid) {
      printWithColor("📱 Android device detected");

      var storageStatus = await Permission.storage.status;
      printWithColor("📦 Storage permission status: $storageStatus");

      if (storageStatus.isDenied) {
        storageStatus = await Permission.storage.request();
        printWithColor("📦 Storage permission after request: $storageStatus");
      }

      var installStatus = await Permission.requestInstallPackages.status;
      printWithColor("📲 Install permission status: $installStatus");

      if (installStatus.isDenied) {
        installStatus = await Permission.requestInstallPackages.request();
        printWithColor("📲 Install permission after request: $installStatus");

        if (installStatus.isDenied || installStatus.isPermanentlyDenied) {
          printWithColor("⚠️ Install permission denied!");
          return false;
        }
      }

      printWithColor("✅ All permissions granted");
      return true;
    }
    return true;
  }

  static Future<void> _downloadAndInstallApk(
      BuildContext rootContext,
      String apkUrl,
      bool isRequired,
      ) async {
    printWithColor("🚀 _downloadAndInstallApk called");
    printWithColor("🔗 URL: $apkUrl");

    if (!rootContext.mounted) {
      printWithColor("❌ Context not mounted at start");
      return;
    }

    bool hasPermission = await _requestPermissions();

    if (!hasPermission) {
      printWithColor("❌ No permission granted");
      if (rootContext.mounted) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          const SnackBar(
            content: Text("⚠️ يجب السماح بتثبيت التطبيقات من مصادر غير معروفة\nسيتم إغلاق التطبيق"),
            duration: Duration(seconds: 3),
          ),
        );
      }
      // إغلاق التطبيق بعد 3 ثواني لأن الأذونات مرفوضة
      Future.delayed(const Duration(seconds: 3), _forceCloseApp);
      return;
    }

    printWithColor("✅ Permissions OK, getting download path...");

    final dirPath = await appDownloadDirectoryPath;
    final filePath = "$dirPath/mehrab_update.apk";

    printWithColor("📁 File path: $filePath");

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      printWithColor("🗑️ Old APK deleted");
    }

    if (!rootContext.mounted) {
      printWithColor("❌ Context not mounted before download");
      return;
    }

    printWithColor("🎨 Showing download dialog...");

    await _startDownloadDirectly(rootContext, apkUrl, filePath, isRequired);
  }

  static Future<void> _startDownloadDirectly(
      BuildContext context,
      String apkUrl,
      String filePath,
      bool isRequired,
      ) async {
    printWithColor("⏬ Starting download directly...");

    if (!context.mounted) {
      printWithColor("❌ Context not mounted in _startDownloadDirectly");
      return;
    }

    final dio = Dio(BaseOptions(
      headers: {
        'Accept': '*/*',
        'User-Agent': 'MehrabApp/1.0',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // ValueNotifier للتحكم في التقدم
    final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
    final ValueNotifier<String> downloadInfoNotifier = ValueNotifier<String>('جارٍ التحميل...');

    late BuildContext? dialogContext;
    if (context.mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (innerContext) {
          dialogContext = innerContext;
          return DownloadProgressDialog(
            progressNotifier: progressNotifier,
            downloadInfoNotifier: downloadInfoNotifier,
          );
        },
      );
    }

    try {
      printWithColor("🌐 Connecting to: $apkUrl");

      await dio.download(
        apkUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            progressNotifier.value = progress;

            // تحويل البايتات إلى ميجابايت
            double receivedMB = received / (1024 * 1024);
            double totalMB = total / (1024 * 1024);
            int percentage = (progress * 100).toInt();

            downloadInfoNotifier.value =
            '${receivedMB.toStringAsFixed(2)} MB / ${totalMB.toStringAsFixed(2)} MB ($percentage%)';

            printWithColor("📊 Progress: $percentage% ($received/$total bytes)");
          } else {
            downloadInfoNotifier.value = 'جارٍ التحميل... ${(received / (1024 * 1024)).toStringAsFixed(2)} MB';
            printWithColor("📊 Received: $received bytes");
          }
        },
      );

      printWithColor("✅ Download completed!");

      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ تم التحميل بنجاح"),
            duration: Duration(seconds: 2),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) {
        printWithColor("❌ Context not mounted before opening file");
        return;
      }

      printWithColor("📱 Opening APK: $filePath");

      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        printWithColor("📦 File exists, size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB");

        final result = await OpenFilex.open(filePath);
        printWithColor("📲 Open result: ${result.type} - ${result.message}");

        if (result.type == ResultType.noAppToOpen) {
          printWithColor("⚠️ No app to open APK - Closing app");
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text("⚠️ تعذر التثبيت"),
                content: const Text(
                  "لا يمكن فتح ملف APK.\n"
                      "قد تحتاج إلى تفعيل 'السماح بتثبيت التطبيقات من مصادر غير معروفة' من الإعدادات.\n\n"
                      "سيتم إغلاق التطبيق الآن.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _forceCloseApp();
                    },
                    child: const Text("حسناً"),
                  ),
                ],
              ),
            );
          }
          // إغلاق التطبيق بعد 5 ثواني حتى لو لم يضغط المستخدم
          Future.delayed(const Duration(seconds: 5), _forceCloseApp);
        } else if (result.type == ResultType.done) {
          // التثبيت بدأ بنجاح - إغلاق التطبيق بعد ثانيتين
          printWithColor("✅ APK opened successfully - Closing app in 2 seconds");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ جارٍ التثبيت... سيتم إغلاق التطبيق"),
                duration: Duration(seconds: 2),
              ),
            );
          }
          Future.delayed(const Duration(seconds: 2), _forceCloseApp);
        } else {
          // أي حالة أخرى - إغلاق التطبيق
          printWithColor("⚠️ Unexpected result type: ${result.type} - Closing app");
          Future.delayed(const Duration(seconds: 3), _forceCloseApp);
        }
      } else {
        printWithColor("❌ File does not exist after download!");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ فشل حفظ الملف - سيتم إغلاق التطبيق"),
              duration: Duration(seconds: 3),
            ),
          );
        }
        // إغلاق التطبيق لأن الملف لم يُحفظ
        Future.delayed(const Duration(seconds: 3), _forceCloseApp);
      }

    } catch (e, stackTrace) {
      printWithColor("❌ Download error: $e");
      printWithColor("📜 StackTrace: $stackTrace");

      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ فشل التحميل: $e"),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // إغلاق التطبيق بعد 3 ثواني في حالة أي خطأ
      printWithColor("⏱️ Closing app in 3 seconds due to download error...");
      Future.delayed(const Duration(seconds: 3), _forceCloseApp);
    } finally {
      progressNotifier.dispose();
      downloadInfoNotifier.dispose();
    }
  }

  static void _forceCloseApp() {
    printWithColor("🚪 Forcing app close...");
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}

// Dialog جديد لعرض التقدم
class DownloadProgressDialog extends StatelessWidget {
  final ValueNotifier<double> progressNotifier;
  final ValueNotifier<String> downloadInfoNotifier;

  const DownloadProgressDialog({
    super.key,
    required this.progressNotifier,
    required this.downloadInfoNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset("assets/json/update.json",height: 85.sp,width: 85.sp),
          const SizedBox(height: 20),
          ValueListenableBuilder<String>(
            valueListenable: downloadInfoNotifier,
            builder: (context, info, child) {
              return Text(
                info,
                style:  TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<double>(
            valueListenable: progressNotifier,
            builder: (context, progress, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.myAppColor),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style:  TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.myAppColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class UpdateDialog extends StatelessWidget {
  final String notes;
  final bool isRequired;
  final VoidCallback onUpdatePressed;

  const UpdateDialog({
    super.key,
    required this.notes,
    required this.isRequired,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return MyAlertDialog(
      width: 60.wR,
      content: Column(
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
          const SizedBox(height: 10),
          Text(
            AppStrings.whatIsNew.tr(context),
            style: TextStyle(fontSize: 16.sp),
          ),
          const SizedBox(height: 5),
          Text(notes, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
      actions: [
        if (!isRequired)
          TextButton(
            child: Text(
              AppStrings.later.tr(context),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.sp,
                fontFamily: 'Cairo',
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ButtonWidget(
          onPressed: onUpdatePressed,
          label: AppStrings.downloadNow.tr(context),
          height: 32,
          width: 30.wR,
        ),
      ],
    );
  }
}