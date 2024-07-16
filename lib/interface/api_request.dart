import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:network_service/constants/enums.dart';
import 'package:network_service/models/failure_state.dart';

abstract class ApiRequest {
  late Map<String, CancelToken> cancelTokens;

  void cancelRequest(String url);

  Future<Either<Response<dynamic>, FailureState>> getResponse({
    required String endPoint,
    required ApiMethods apiMethods,
    Map<String, dynamic>? queryParams,
    dynamic body,
    Options? options,
    bool hasInternet = true,
  });

  Future<Either<Response<dynamic>, FailureState>> decodeHttpRequestResponse(
    Future<dynamic> apiCall, {
    String message = "",
    required String uniqueKey,
  });

  Future<Either<Response<dynamic>, FailureState>> uploadAnySingleFile({
    required String endPoint,
    required File file,
    required FormData formData,
    required String key,
    required UploadType uploadType,
  });

  Future<Either<Response<dynamic>, FailureState>> uploadAnyMultipleFile({
    required String endPoint,
    required List<File> files,
    required FormData formData,
    required String key,
    required UploadType uploadType,
  });
}
