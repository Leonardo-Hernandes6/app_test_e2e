import 'package:app_test_e2e/core/network/auth_interceptor.dart';
import 'package:app_test_e2e/data/datasources/secure_storage_datasource.dart';
import 'package:dio/dio.dart';

abstract final class DioConfig {
  static Dio createDio({
    required String baseUrl,
    required SecureStorageDatasource secureStorage,
  }) => Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
    ),
  )..interceptors.add(AuthInterceptor(secureStorage));
}
