import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

String generateUniqueKeyBasedOnApi({
  required String path,
  required Map<String, dynamic> queryParameters,
  required dynamic data,
}) {
  String key = path;
  try {
    if (queryParameters.isNotEmpty) {
      key = key + jsonEncode(queryParameters);
    }
    if (data != null && data is! FormData) {
      key = key + jsonEncode(data);
    }
  } catch (e) {
    log("::: Unique Key Generation Error ::: $path, $queryParameters, $data :::");
  }
  return key;
}
