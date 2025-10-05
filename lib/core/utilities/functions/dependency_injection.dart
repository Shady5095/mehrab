import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../../features/prayer_times/data/data_sources/prayer_times_remote_repo_impl.dart';
import '../../../features/prayer_times/data/repositories/prayer_times_repo_impl.dart';
import '../services/api_service.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<ApiService>(() => ApiService(Dio()));
  getIt.registerLazySingleton<PrayerTimesRepoImpl>(()=> PrayerTimesRepoImpl(PrayerTimesRemoteRepoImpl(getIt.get<ApiService>())));
}
