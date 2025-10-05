import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/location_model.dart';
import '../entities/prayer_times_entity.dart';

abstract class PrayerTimesRepo {
  Future<Either<Failure, PrayerTimesEntity>> getPrayerTime({
    required String day,
    required String longitude,
    required String latitude,
  });

  Future<Either<Failure, LocationModel>> getLocationInfo({required String ip});
}
