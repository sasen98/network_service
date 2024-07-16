import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:network_service/constants/enums.dart';
import 'package:network_service/interface/api_request.dart';
import 'package:network_service/models/failure_state.dart';
import 'package:network_service/network_service.dart';
import 'package:network_service/utils/network_utils.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:path/path.dart' as path;

class ApiRequestImpl implements ApiRequest {
  @override
  Future<Either<Response<dynamic>, FailureState>> getResponse({
    required String endPoint,
    required ApiMethods apiMethods,
    Map<String, dynamic>? queryParams,
    body,
    Options? options,
    bool hasInternet = true,
  }) async {
    var apiManager = NetworkService.apiManager;
    String url = endPoint;

    late Either<Response<dynamic>, FailureState> responseData;

    Map<String, dynamic> extras = {};

    String cancelURL = generateUniqueKeyBasedOnApi(
      path: endPoint,
      queryParameters: queryParams ?? {},
      data: body,
    );

    Options newOptions = options ?? Options();
    newOptions.extra = extras;

    var cancelToken = CancelToken();
    cancelTokens.addAll({cancelURL: cancelToken});

    switch (apiMethods) {
      case ApiMethods.post:
        responseData = await decodeHttpRequestResponse(
          apiManager.dio!.post(
            url,
            cancelToken: cancelToken,
            data: body,
            options: newOptions,
            queryParameters: queryParams,
          ),
          uniqueKey: cancelURL,
        );
      case ApiMethods.delete:
        responseData = await decodeHttpRequestResponse(
          apiManager.dio!.delete(
            url,
            data: body,
            options: newOptions,
            queryParameters: queryParams,
          ),
          uniqueKey: cancelURL,
        );
      case ApiMethods.get:
      default:
        responseData = await decodeHttpRequestResponse(
          apiManager.dio!.get(
            url,
            options: newOptions,
            queryParameters: queryParams,
          ),
          uniqueKey: cancelURL,
        );
    }

    return responseData;
  }

  @override
  Future<Either<Response<dynamic>, FailureState>> decodeHttpRequestResponse(
      Future<dynamic> apiCall,
      {String message = "",
      required String uniqueKey}) async {
    try {
      Response? response = await apiCall;
      List<int> successStatusCode = [200, 201];

      if (successStatusCode.contains(response?.statusCode)) {
        return Left(response!);
      } else if (response?.statusCode == 500) {
        return Right(FailureState(message: 'Something went wrong'));
      } else if (response?.statusCode == 401) {
        return Right(FailureState(message: 'Something went wrong'));
      } else if (response?.statusCode == 400) {
        return Right(FailureState.fromJson(response!.data));
      } else if (response?.statusCode == 422) {
        return Right(FailureState.fromJson(response!.data));
      } else if (response?.data == null) {
        return Right(response?.data);
      } else {
        return Right(FailureState(message: 'Something went wrong'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Right(FailureState(message: 'Unauthorized Access'));
      } else if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 422) {
        FailureState failureState = FailureState.fromJson(e.response?.data);
        failureState =
            failureState.copyWith(statusCode: e.response?.statusCode);
        return Right(failureState);
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {}
      return Right(FailureState(
        message: 'Something went wrong',
      ));
    } catch (e) {
      return Right(FailureState(message: 'Something went wrong'));
    }
  }

  @override
  Map<String, CancelToken> cancelTokens = {};

  @override
  void cancelRequest(String url) {
    if (cancelTokens.containsKey(url)) {
      final token = cancelTokens[url];
      if (token != null) {
        token.cancel("Cancelled $url");
      }
      cancelTokens.removeWhere((key, value) => key == url);
    }
  }

  @override
  Future<Either<Response<dynamic>, FailureState>> uploadAnyMultipleFile({
    required String endPoint,
    required List<File> files,
    required FormData formData,
    required String key,
    required UploadType uploadType,
  }) async {
    FormData formData0 = formData;
    await Future.forEach(files, (file) async {
      String fileName = file.path.split('/').last;
      MultipartFile multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType(
          (uploadType != UploadType.audio || uploadType != UploadType.pdf)
              ? "image"
              : uploadType.toString(),
          path.extension(path.basename(file.path)).replaceAll('.', ''),
        ),
      );
      formData0.files.add(MapEntry(key, multipartFile));
    });
    return getResponse(
      apiMethods: ApiMethods.post,
      endPoint: endPoint,
      body: formData0,
    );
  }

  @override
  Future<Either<Response<dynamic>, FailureState>> uploadAnySingleFile({
    required String endPoint,
    required File file,
    required FormData formData,
    required String key,
    required UploadType uploadType,
  }) async {
    FormData formData0 = formData;
    String fileName = file.path.split('/').last;
    MultipartFile multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: MediaType(
        (uploadType != UploadType.audio || uploadType != UploadType.pdf)
            ? "image"
            : uploadType.toString(),
        path.extension(path.basename(file.path)).replaceAll('.', ''),
      ),
    );
    formData0.files.add(MapEntry(key, multipartFile));
    return getResponse(
      apiMethods: ApiMethods.post,
      endPoint: endPoint,
      body: formData0,
    );
  }
}
