import 'package:app_test_e2e/core/network/api_config.dart';
import 'package:dio/dio.dart';

class E2EBackend {
  E2EBackend()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.fromEnvironment().apiBaseUrl,
          connectTimeout: const Duration(seconds: 3),
        ),
      );

  final Dio _dio;

  Future<void> ensureReachable() async {
    try {
      await _dio.get<void>('/health');
    } on DioException catch (error) {
      throw StateError(
        'Demo API unreachable at ${_dio.options.baseUrl}. '
        'Start it with `./scripts/run_e2e.sh` or '
        '`cd server && dart run bin/server.dart`. ($error)',
      );
    }
  }

  Future<void> reset() => _dio.post<void>('/test/reset');

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) => _dio.post<void>(
    '/auth/register',
    data: {'name': name, 'email': email, 'password': password},
  );
}
