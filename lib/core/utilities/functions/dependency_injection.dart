import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../services/api_service.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<ApiService>(() => ApiService(Dio()));


}
