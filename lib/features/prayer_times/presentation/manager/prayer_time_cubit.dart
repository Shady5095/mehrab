import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utilities/functions/print_with_color.dart';
import '../../../../core/utilities/services/cache_service.dart';
import '../../data/models/location_model.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../../domain/use_cases/get_loaction_info_use_case.dart';
import '../../domain/use_cases/get_prayer_time_use_case.dart';

part 'prayer_time_state.dart';

class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  PrayerTimeCubit({
    required this.getPrayerTimeUseCase,
    required this.getLocationInfoUseCase,
  }) : super(PrayerTimeInitial());

  static PrayerTimeCubit instance(BuildContext context) =>
      BlocProvider.of(context);

  final GetPrayerTimeUseCase getPrayerTimeUseCase;
  final GetLocationInfoUseCase getLocationInfoUseCase;

  PrayerTimesEntity? prayerTimesEntity;

  Future<void> getPrayerTime({String? day}) async {
    final String initialDay = DateFormat('dd-MM-yyyy').format(DateTime.now());
    emit(PrayerTimeLoading());
    final result = await getPrayerTimeUseCase.call(
      day: day ?? initialDay,
      longitude: await getLatitudeAndLongitude().then((value) => value[0]),
      latitude: await getLatitudeAndLongitude().then((value) => value[1]),
    );
    result.fold(
      (failure) {
        printWithColor(failure.errorMessage);
        emit(PrayerTimeError(failure.errorMessage));
      },
      (prayerTimes) {
        prayerTimesEntity = prayerTimes;
        emit(PrayerTimeSuccess());
      },
    );
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

  Future<LocationModel> getLocationInfo() async {
    LocationModel locationModel = LocationModel(
      countryName: 'Egypt',
      regionName: 'Africa',
      cityName: 'Cairo',
      latitude: 30.033333,
      longitude: 31.233334,
    );
    final result = await getLocationInfoUseCase.call(
      ip: await getCurrentIpWithDio(),
    );
    result.fold((failure) {}, (location) {
      locationModel = location;
    });
    return locationModel;
  }

  Future<List<String>> getLatitudeAndLongitude() async {
    List<String> latLong = [];
    String? latitude = CacheService.getData(key: 'latitude');
    String? longitude = CacheService.getData(key: 'longitude');
    if (latitude == null || longitude == null) {
      final LocationModel locationModel = await getLocationInfo();
      latitude = locationModel.latitude.toString();
      longitude = locationModel.longitude.toString();
      CacheService.setData(key: 'latitude', value: latitude);
      CacheService.setData(key: 'longitude', value: longitude);
      latLong = [longitude, latitude];
    } else {
      latLong = [longitude, latitude];
    }

    return latLong;
  }
}
