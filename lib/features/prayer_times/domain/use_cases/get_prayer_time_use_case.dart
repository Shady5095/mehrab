import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/prayer_times_entity.dart';
import '../repositories/prayer_times_repo.dart';

class GetPrayerTimeUseCase {
  final PrayerTimesRepo repo;

  GetPrayerTimeUseCase(this.repo);

  Future<Either<Failure, PrayerTimesEntity>> call({
    required String day,
    required String longitude,
    required String latitude,
  }) async {
    return repo.getPrayerTime(
      day: day,
      longitude: longitude,
      latitude: latitude,
    );
  }
}
