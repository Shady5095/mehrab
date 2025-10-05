
import '../../domain/entities/prayer_times_entity.dart';
import '../models/location_model.dart';

abstract class PrayerTimesRemoteRepo {
  Future<PrayerTimesEntity> getPrayerTime({
    required String day,
    required String longitude,
    required String latitude,
  });

  Future<LocationModel> getLocationInfo({
    required String ip,
  });
}
