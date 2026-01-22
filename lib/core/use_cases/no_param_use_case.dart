import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';

abstract class UseCase<T> {
  Future<Either<Failure, T>> call();
}
