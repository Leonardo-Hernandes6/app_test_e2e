import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:dio/dio.dart';

Future<Result<T>> guardRequest<T>(Future<T> Function() request) async {
  try {
    return Ok(await request());
  } on DioException catch (error) {
    return Err(mapDioException(error));
  }
}

Failure mapDioException(DioException error) {
  final response = error.response;
  if (response == null) return const NetworkFailure();

  final data = response.data;
  final code = data is Map ? data['code'] : null;
  final message = data is Map ? data['message'] : null;

  return switch ((response.statusCode, code)) {
    (_, 'invalid_credentials') => const InvalidCredentialsFailure(),
    (_, 'email_already_in_use') => const EmailAlreadyInUseFailure(),
    (_, 'validation_error') => ValidationFailure(
      message is String ? message : '',
    ),
    (401, _) => const UnauthorizedFailure(),
    (404, _) => const NotFoundFailure(),
    (final status, _) => ServerFailure(status),
  };
}
