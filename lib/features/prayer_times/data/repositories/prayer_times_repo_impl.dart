import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';


import '../../../../core/errors/failure.dart';
import '../../../../core/errors/server_failure.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../../domain/repositories/prayer_times_repo.dart';
import '../data_sources/prayer_times_remote_repo.dart';
import '../models/location_model.dart';

class PrayerTimesRepoImpl implements PrayerTimesRepo {
  final PrayerTimesRemoteRepo remoteRepo;

  PrayerTimesRepoImpl(this.remoteRepo);

  @override
  Future<Either<Failure, PrayerTimesEntity>> getPrayerTime({
    required String day,
    required String longitude,
    required String latitude,
  }) async {
    try {
      final model = await remoteRepo.getPrayerTime(
        day: day,
        longitude: longitude,
        latitude: latitude,
      );
      return Right(model);
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LocationModel>> getLocationInfo({
    required String ip,
  }) async {
    try {
      final model = await remoteRepo.getLocationInfo(ip: ip);
      return Right(model);
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
