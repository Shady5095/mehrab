import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../../features/prayer_times/data/data_sources/prayer_times_remote_repo_impl.dart';
import '../../../features/prayer_times/data/repositories/prayer_times_repo_impl.dart';
import '../../config/app_config.dart';
import '../services/api_service.dart';
import '../services/audio_session_service.dart';
import '../services/livekit_token_service.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<ApiService>(() => ApiService(Dio()));
  getIt.registerLazySingleton<PrayerTimesRepoImpl>(() => PrayerTimesRepoImpl(PrayerTimesRemoteRepoImpl(getIt.get<ApiService>())));

  // LiveKit Services
  getIt.registerFactory<AudioSessionService>(() => AudioSessionService());
  getIt.registerLazySingleton<LiveKitTokenService>(
    () => LiveKitTokenService(
      apiUrl: AppConfig.livekitApiUrl,
    ),
  );
}
