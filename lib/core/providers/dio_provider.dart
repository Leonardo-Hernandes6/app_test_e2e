import 'package:app_test_e2e/core/network/api_config.dart';
import 'package:app_test_e2e/core/network/dio_config.dart';
import 'package:app_test_e2e/core/providers/secure_storage_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.fromEnvironment(),
);

final dioProvider = Provider<Dio>((ref) {
  final dio = DioConfig.createDio(
    baseUrl: ref.watch(apiConfigProvider).apiBaseUrl,
    secureStorage: ref.watch(secureStorageDatasourceProvider),
  );
  ref.onDispose(dio.close);
  return dio;
});
