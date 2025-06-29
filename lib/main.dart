import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'app/my_app.dart';
import 'core/utilities/functions/bloc_observer.dart';
import 'core/utilities/functions/dependency_injection.dart';
import 'core/utilities/services/api_service.dart';
import 'core/utilities/services/local_notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  setup();
  HttpOverrides.global =
      MyHttpOverrides(); // To handle android blew 8 http connection
  // await checkVersionAndClearAppData();
  await Future.wait([
    LocalNotificationsService.init(),
    FlutterDownloader.initialize(),
    //Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) {
        return Phoenix(child: const MyApp());
      },
    ),
  );

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