import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../utilities/resources/strings.dart';
import 'failure.dart';

class ServerFailure extends Failure {
  final int? statusCode;

  ServerFailure(super.errorMessage, {this.statusCode, super.errorDetails});

  factory ServerFailure.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(AppStrings.connectionTimeoutFromApiServer);
      case DioExceptionType.receiveTimeout:
        return ServerFailure(AppStrings.receiveTimeoutFromApiServer);
      case DioExceptionType.badCertificate:
        return ServerFailure(AppStrings.incorrectCertificate);
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          dioException.response?.statusCode ?? 0,
          dioException.response?.data,
        );
      case DioExceptionType.cancel:
        return ServerFailure(AppStrings.cancelFromApiServer);
      case DioExceptionType.connectionError:
        return ServerFailure(AppStrings.checkConnection);
      case DioExceptionType.sendTimeout:
        return ServerFailure(AppStrings.sendTimeoutFromApiServer);
      case DioExceptionType.unknown:
        return ServerFailure(AppStrings.somethingWentWrongTryAgain);
    }
  }

  factory ServerFailure.fromResponse(int errorNumber, dynamic response) {
    log('********************************************************************');
    log(response['message'].toString());
    log(
      '**********************************************************************',
    );
    if (errorNumber == 400 ||
        errorNumber == 401 ||
        errorNumber == 403 ||
        errorNumber == 422) {
      return ServerFailure(
        response['message'].toString(),
        statusCode: errorNumber,
      );
    } else if (errorNumber == 404) {
      return ServerFailure(AppStrings.methodNotFound);
    } else if (errorNumber == 500) {
      return ServerFailure(AppStrings.internalServerError);
    } else {
      return ServerFailure(AppStrings.oopsTryAgain);
    }
  }
}

class CacheFailure extends Failure {
  CacheFailure(super.errorMessage);

  factory CacheFailure.fromError(FileSystemException fileSystemException) {
    switch (fileSystemException.osError?.errorCode) {
      case 2:
        return CacheFailure(fileSystemException.message);
      case 13:
        return CacheFailure(fileSystemException.message);
      default:
        return CacheFailure(AppStrings.somethingWentWrongTryAgain);
    }
  }
}
