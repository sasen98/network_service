import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:network_service/interface/api_manager.dart';
import 'package:network_service/interface/api_request.dart';

class NetworkService {
  /// private constructor so you cannot create an instance from outside the class using this constructor.
  NetworkService._();

  /// _instance holds the single instance of NetworkService
  static final NetworkService _instance = NetworkService._();

  ///This constructor doesn't create a new instance of the class; instead, it returns the existing _instance. This ensures that every time you call NetworkService(), you get the same instance.
  factory NetworkService() => _instance;

  static late ApiRequest _apiRequest;
  static late ApiManager _apiManager;

  static ApiRequest get apiRequest => _apiRequest;

  static ApiManager get apiManager => _apiManager;

  static Future<void> configureNetworkService({
    String baseURL = "",
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 25),
    String contentType = Headers.jsonContentType,
    Map<String, dynamic> headers = const {"Accept": "application/json"},
    String? pemCertificate,
    Uint8List? localCertificateBytes,
    bool isDevEnv = false,
  }) async {
    NetworkService._apiManager.initialize(
      baseURL: baseURL,
      headers: headers,
      connectTimeout: connectTimeout,
      contentType: contentType,
      isToEnableSSLCertificate: isDevEnv
          ? false
          : (pemCertificate != null) || (localCertificateBytes != null),
      localCertificateBytes: localCertificateBytes,
      pemCertificate: pemCertificate,
      receiveTimeout: receiveTimeout,
    );
  }
}
