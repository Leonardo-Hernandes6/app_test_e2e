import 'package:app_test_e2e/core/utils/error_handler.dart';
import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _httpError(int status, [Map<String, dynamic>? body]) {
  final options = RequestOptions(path: '/any');
  return DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  group('guardRequest', () {
    test('sucesso: devolve o valor em Ok', () async {
      final result = await guardRequest(() async => 42);

      expect(result, isA<Ok<int>>().having((ok) => ok.value, 'value', 42));
    });

    test('erro do Dio: devolve Err com a falha', () async {
      final result = await guardRequest<int>(
        () => Future.error(_httpError(500)),
      );

      expect(
        result,
        isA<Err<int>>().having(
          (e) => e.failure,
          'failure',
          const ServerFailure(500),
        ),
      );
    });
  });

  group('mapDioException', () {
    test('sem resposta: NetworkFailure', () {
      final error = DioException.connectionError(
        requestOptions: RequestOptions(path: '/any'),
        reason: 'refused',
      );

      expect(mapDioException(error), const NetworkFailure());
    });

    test('código de erro da API: falha correspondente', () {
      expect(
        mapDioException(_httpError(401, {'code': 'invalid_credentials'})),
        const InvalidCredentialsFailure(),
      );
      expect(
        mapDioException(_httpError(409, {'code': 'email_already_in_use'})),
        const EmailAlreadyInUseFailure(),
      );
      expect(
        mapDioException(
          _httpError(422, {'code': 'validation_error', 'message': 'Inválido'}),
        ),
        const ValidationFailure('Inválido'),
      );
    });

    test('sem código de erro: falha pelo status HTTP', () {
      expect(mapDioException(_httpError(401)), const UnauthorizedFailure());
      expect(mapDioException(_httpError(404)), const NotFoundFailure());
      expect(mapDioException(_httpError(503)), const ServerFailure(503));
    });
  });
}
