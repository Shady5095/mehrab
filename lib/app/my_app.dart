import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/config/routes/app_routes.dart';
import '../core/config/themes/app_dark_theme.dart';
import '../core/config/themes/app_light_theme.dart';
import '../core/utilities/functions/dependency_injection.dart';
import '../core/utilities/resources/constants.dart';
import '../core/utilities/resources/size_config.dart';
import '../core/utilities/services/cache_service.dart';
import '../core/widgets/change_system_navigation_theme.dart';
import '../features/prayer_times/data/repositories/prayer_times_repo_impl.dart';
import '../features/prayer_times/domain/use_cases/get_loaction_info_use_case.dart';
import 'app_locale/app_locale.dart';
import 'main_app_cubit/main_app_cubit.dart';
import 'main_app_cubit/main_app_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MainAppCubit(
            getLocationInfoUseCase: GetLocationInfoUseCase(
              getIt<PrayerTimesRepoImpl>(),
            ),
          )
            ..getLocationInfo()
            ..initializeLanguage(
              cachedLanguage: CacheService.getData(
                key: AppConstants.currentLanguage,
              ),
              systemLocale: const Locale('ar'), // أو احصل عليها من النظام
            )
            ..setCurrentIndex(
              cacheThemValue: CacheService.getData(
                key: AppConstants.themeMode,
              ),
            )
            ..setStatusBarColor(),
        ),
      ],
      child: BlocBuilder<MainAppCubit, MainAppStates>(
        buildWhen: (previous, current) =>
        current is! MainAppInitial ||
            current is! MainAppChangeFileState,
        builder: (context, state) {
          final MainAppCubit cubit = MainAppCubit.instance(context);
          return ChangeSystemNavigationBarTheme(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: const [
                AppLocale.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
                Locale('tr'),
                Locale('de'),
              ],
              locale: cubit.setAppLanguage(),
              debugShowCheckedModeBanner: false,
              theme: AppLightThemes.appLightTheme(context),
              builder: DevicePreview.appBuilder,
              darkTheme: AppDarkThemes.appDarkTheme(context),
              themeMode: ThemeMode.light,
              onGenerateRoute: RouteGenerator.generateRoute,
              initialRoute: cubit.checkNextRoute,
              navigatorObservers: [AppRouteObserver()],
            ),
          );
        },
      ),
    );
  }
}