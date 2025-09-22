import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import '../../core/config/routes/app_routes.dart';
import '../../core/utilities/resources/colors.dart';
import '../../core/utilities/resources/constants.dart';
import '../../core/utilities/services/cache_service.dart';
import '../../core/widgets/icon_broken.dart';
import '../../features/prayer_times/domain/use_cases/get_loaction_info_use_case.dart';
import 'main_app_state.dart';

class MainAppCubit extends Cubit<MainAppStates> {
  MainAppCubit({
    required this.getLocationInfoUseCase,
})
    : super(MainAppInitial());
  final GetLocationInfoUseCase getLocationInfoUseCase;
  static MainAppCubit instance(BuildContext context) =>
      BlocProvider.of(context);

  bool isEnglish = true;
  int currentIndex = 2;
  int? totalUnseenNotification;
  int? totalUnseenAnnouncement;


  Color setEnglishColor(BuildContext context) {
    if (isEnglish) {
      return AppColors.accentColor;
    }
    return context.backgroundColor;
  }

  Color setArabicColor(BuildContext context) {
    if (isEnglish) {
      return context.backgroundColor;
    }
    return AppColors.accentColor;
  }

  void englishFunction({
    bool? isEnglishCache,
    Locale? systemLocale,
  }) {
    if (isEnglishCache != null) {
      isEnglish = isEnglishCache;
    } else {
      if (systemLocale != null) {
        isEnglish = systemLocale.languageCode == 'en';
      } else {
        isEnglish = true; // fallback default
      }
    }
    CacheService.setData(key: AppConstants.isEnglish, value: isEnglish);
    emit(MainAppChangeLangState());
  }


  void setCurrentIndex({int? index, int? cacheThemValue}) {
    if (cacheThemValue != null) {
      currentIndex = cacheThemValue;
    } else {
      if (currentIndex != index) {
        currentIndex = index ?? 2;
        emit(MainAppChangeModeState());
        CacheService.setData(key: AppConstants.themeMode, value: currentIndex);
      }
    }
  }


  Color setLangColor(int index) {
    if (currentIndex == index) {
      return AppColors.accentColor;
    } else {
      return Colors.transparent;
    }
  }

  bool isSystemModeDark(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      return true;
    } else {
      return false;
    }
  }

  Color? systemNavBarColor(BuildContext context) {
    switch (currentIndex) {
      case 0:
        return AppColors.blackColor;
      case 2:
        if (isSystemModeDark(context)) {
          return AppColors.blackColor;
        } else {
          return Colors.transparent.withValues(alpha: 0);
        }
      default:
        return Colors.transparent.withValues(alpha: 0);
    }
  }

  ThemeMode get themeMode {
    switch (currentIndex) {
      case 0:
        return ThemeMode.dark;
      case 1:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void arabicFunction() {
    if (isEnglish) {
      isEnglish = false;
      CacheService.setData(key: AppConstants.isEnglish, value: isEnglish);
      emit(MainAppChangeLangState());
    }
  }

  Locale setAppLanguage() {
    if (isEnglish) {
      return const Locale(AppConstants.en);
    }
    return const Locale(AppConstants.ar);
  }

  IconData changeArrow() {
    if (isEnglish) {
      return IconBroken.Arrow___Left_2;
    }
    return IconBroken.Arrow___Right_2;
  }

  String setFontFamily() {
    if (isEnglish) {
      return AppConstants.englishFont;
    }
    return AppConstants.arabicFont;
  }

  String get checkNextRoute {
    CacheService.userRole = CacheService.getData(key: AppConstants.userRole);
    CacheService.uid = CacheService.getData(key: AppConstants.uid);
    if(CacheService.uid != null){
      if(CacheService.userRole == "student" || CacheService.userRole == "admin"|| CacheService.userRole == "teacher"){
        return AppRoutes.homeLayoutRoute;
      }
    }
    return AppRoutes.loginRoute;
  }
  Future<void> getLocationInfo() async {
    final currentCountryCode = CacheService.getData(key: 'currentCountryCode');
    if(currentCountryCode != null){
      CacheService.currentCountryCode = currentCountryCode;
      return;
    }
    final result = await getLocationInfoUseCase.call(
      ip: await getCurrentIpWithDio(),
    );
    result.fold((failure) {}, (location) {
      CacheService.setData(key: 'currentCountryCode', value: location.countryCode);
      CacheService.currentCountryCode = location.countryCode;
    });
  }
  Future<String> getCurrentIpWithDio() async {
    // Check the current connectivity status (Wi-Fi or mobile data)
    final List<ConnectivityResult> results =
    await Connectivity().checkConnectivity();

    // Check if Wi-Fi is among the active connections
    if (results.contains(ConnectivityResult.wifi)) {
      // Get the local IP address when connected to Wi-Fi
      return getLocalIpWithDio();
    }
    // Check if mobile data is among the active connections
    else if (results.contains(ConnectivityResult.mobile)) {
      // Get the public IP address when connected to mobile data
      return getPublicIpWithDio();
    } else {
      return 'No Internet Connection';
    }
  }

  Future<String> getLocalIpWithDio() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'http://api.ipify.org?format=json',
      ); // Example of fetching public IP
      return response.data['ip'];
    } catch (e) {
      return 'Failed to fetch local IP';
    }
  }

  Future<String> getPublicIpWithDio() async {
    try {
      final dio = Dio();
      final response = await dio.get('https://api.ipify.org?format=json');
      return response.data['ip'];
    } catch (e) {
      return 'Failed to fetch public IP';
    }
  }


}
