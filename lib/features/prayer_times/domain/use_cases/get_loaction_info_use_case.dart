import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/location_model.dart';
import '../repositories/prayer_times_repo.dart';

class GetLocationInfoUseCase {
  final PrayerTimesRepo repo;

  GetLocationInfoUseCase(this.repo);

  Future<Either<Failure, LocationModel>> call({required String ip}) async {
    return repo.getLocationInfo(ip: ip);
  }
}
