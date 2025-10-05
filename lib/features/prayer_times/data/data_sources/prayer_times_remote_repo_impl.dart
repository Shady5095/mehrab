import '../../../../core/utilities/services/api_service.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../models/location_model.dart';
import '../models/prayer_time_model.dart';
import 'prayer_times_remote_repo.dart';

class PrayerTimesRemoteRepoImpl implements PrayerTimesRemoteRepo {
  final ApiService apiService;

  PrayerTimesRemoteRepoImpl(this.apiService);

  @override
  Future<PrayerTimesEntity> getPrayerTime({
    required String day,
    required String longitude,
    required String latitude,
  }) async {
    final response = await apiService.getSpatialRequest(
      baseUrl: 'api.aladhan.com/v1/timings/$day',
      data: {'latitude': latitude, 'longitude': longitude},
    );
    final PrayerTimeModel prayerTimeModel = PrayerTimeModel.fromJson(
      response?.data,
    );
    final PrayerTimesEntity prayer =
        prayerTimeModel.data ??
        PrayerTimesEntity(
          locationName: 'Egypt',
          fajrTime: '4:58 am',
          duhurTime: '12:27 pm',
          asrTime: '3:54 pm',
          maghribTime: '6:36 pm',
          ishaTime: '8:36 pm',
          sunriseTime: '6:00 am',
          midNightTime: '12:00 am',
          sunsetTime: '6:00 pm',
        );
    return prayer;
  }

  @override
  Future<LocationModel> getLocationInfo({required String ip}) async {
    final response = await apiService.getSpatialRequest(
      baseUrl: 'api.ip2location.io',
      data: {'key': 'A8560F1F96D82A84F66E00C52DF84F3A', 'ip': ip},
    );
    final LocationModel locationModel = LocationModel.fromJson(response?.data);
    return locationModel;
  }
}
