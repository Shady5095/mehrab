import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  }) : super(MainAppInitial());

  final GetLocationInfoUseCase getLocationInfoUseCase;

  static MainAppCubit instance(BuildContext context) =>
      BlocProvider.of(context);

  String currentLanguage = 'ar'; // القيمة الافتراضية
  int currentIndex = 2;
  int? totalUnseenNotification;
  int? totalUnseenAnnouncement;

  // دالة موحدة لتغيير اللغة
  void changeLanguage(String langCode) {
    if (currentLanguage != langCode) {
      currentLanguage = langCode;
      CacheService.setData(key: AppConstants.currentLanguage, value: langCode);
      emit(MainAppChangeLangState());
    }
  }

  // دالة لتحديد لون اللغة المختارة
  Color setLanguageColor(BuildContext context, String langCode) {
    if (currentLanguage == langCode) {
      return AppColors.accentColor;
    }
    return context.backgroundColor;
  }

  // تعيين اللغة من الكاش أو النظام
  void initializeLanguage({
    String? cachedLanguage,
    Locale? systemLocale,
  }) {
    if (cachedLanguage != null) {
      currentLanguage = cachedLanguage;
    } else if (systemLocale != null) {
      // التحقق من اللغات المدعومة
      if (['en', 'ar', 'tr','de'].contains(systemLocale.languageCode)) {
        currentLanguage = systemLocale.languageCode;
      } else {
        currentLanguage = 'ar'; // اللغة الافتراضية
      }
    }
    CacheService.setData(key: AppConstants.currentLanguage, value: currentLanguage);
    emit(MainAppChangeLangState());
  }

  // دالة لإرجاع Locale بناءً على اللغة الحالية
  Locale setAppLanguage() {
    return Locale(currentLanguage);
  }

  // للتوافق مع الكود القديم
  bool get isEnglish => currentLanguage == 'en';
  bool get isArabic => currentLanguage == 'ar';
  bool get isTurkish => currentLanguage == 'tr';
  bool get isGerman => currentLanguage == 'de';

  Color setEnglishColor(BuildContext context) {
    return setLanguageColor(context, 'en');
  }

  Color setArabicColor(BuildContext context) {
    return setLanguageColor(context, 'ar');
  }

  Color setTurkishColor(BuildContext context) {
    return setLanguageColor(context, 'tr');
  }

  Color setGermany(BuildContext context) {
    return setLanguageColor(context, 'de');
  }

  void englishFunction({
    bool? isEnglishCache,
    Locale? systemLocale,
  }) {
    changeLanguage('en');
  }

  void arabicFunction() {
    changeLanguage('ar');
  }

  void turkishFunction() {
    changeLanguage('tr');
  }

  void germanFunction() {
    changeLanguage('de');
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

  IconData changeArrow() {
    // العربية والتركية من اليمين لليسار
    if (currentLanguage == 'ar' || currentLanguage == 'tr') {
      return IconBroken.Arrow___Right_2;
    }
    return IconBroken.Arrow___Left_2;
  }

  String setFontFamily() {
    // يمكنك إضافة خط خاص باللغة التركية إذا أردت
    if (currentLanguage == 'tr') {
      return AppConstants.arabicFont; // أضف هذا الثابت في constants
    }
    return AppConstants.arabicFont;
  }

  String get checkNextRoute {
    CacheService.userRole = CacheService.getData(key: AppConstants.userRole);
    CacheService.uid = CacheService.getData(key: AppConstants.uid);
    if (CacheService.uid != null) {
      if (CacheService.userRole == "student" ||
          CacheService.userRole == "admin" ||
          CacheService.userRole == "teacher" || CacheService.userRole == "teacherTest") {
        return AppRoutes.homeLayoutRoute;
      }
    } else if (CacheService.getData(key: 'onBoarding') != true) {
      return AppRoutes.startScreenRoute;
    }
    return AppRoutes.loginRoute;
  }

  Future<void> getLocationInfo() async {
    final currentCountryCode = CacheService.getData(key: 'currentCountryCode');
    if (currentCountryCode != null) {
      CacheService.currentCountryCode = currentCountryCode;
      return;
    }
    final result = await getLocationInfoUseCase.call(
      ip: await getCurrentIpWithDio(),
    );
    result.fold((failure) {}, (location) {
      CacheService.setData(
          key: 'currentCountryCode', value: location.countryCode);
      CacheService.currentCountryCode = location.countryCode;
    });
  }

  Future<String> getCurrentIpWithDio() async {
    final List<ConnectivityResult> results =
    await Connectivity().checkConnectivity();

    if (results.contains(ConnectivityResult.wifi)) {
      return getLocalIpWithDio();
    } else if (results.contains(ConnectivityResult.mobile)) {
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
      );
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

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }
}