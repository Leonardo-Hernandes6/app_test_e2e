import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/data/datasources/auth_remote_datasource.dart';
import 'package:app_test_e2e/data/datasources/secure_storage_datasource.dart';
import 'package:app_test_e2e/data/models/session_model.dart';
import 'package:app_test_e2e/data/models/user_model.dart';
import 'package:app_test_e2e/data/repositories/auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockRemote extends Mock implements AuthRemoteDatasource {}

class _MockSecureStorageDatasource extends Mock
    implements SecureStorageDatasource {}

const _userModel = UserModel(
  id: 'u1',
  name: 'Ana Souza',
  email: 'ana@demo.com',
);

DioException _unauthorized() {
  final options = RequestOptions(path: '/auth/me');
  return DioException.badResponse(
    statusCode: 401,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 401),
  );
}

void main() {
  late _MockRemote remote;
  late _MockSecureStorageDatasource storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    storage = _MockSecureStorageDatasource();
    repository = AuthRepositoryImpl(remote: remote, secureStorage: storage);

    when(() => storage.write(any())).thenAnswer((_) async {});
    when(storage.clear).thenAnswer((_) async {});
  });

  test(
    'AuthRepositoryImpl | login: salva o token e devolve o usuário',
    () async {
      when(
        () => remote.login(email: 'ana@demo.com', password: '123456'),
      ).thenAnswer(
        (_) async => const SessionModel(token: 'token-1', user: _userModel),
      );

      final result = await repository.login(
        email: 'ana@demo.com',
        password: '123456',
      );

      expect(result, isA<Ok<dynamic>>().having((ok) => ok.value, 'value', ana));
      verify(() => storage.write('token-1')).called(1);
    },
  );

  group('AuthRepositoryImpl | restaurar sessão', () {
    test('sem token salvo: devolve null sem chamar a API', () async {
      when(storage.read).thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      expect(
        result,
        isA<Ok<dynamic>>().having((ok) => ok.value, 'value', null),
      );
      verifyNever(remote.currentUser);
    });

    test('token válido: devolve o usuário', () async {
      when(storage.read).thenAnswer((_) async => 'token-1');
      when(remote.currentUser).thenAnswer((_) async => _userModel);

      final result = await repository.restoreSession();

      expect(result, isA<Ok<dynamic>>().having((ok) => ok.value, 'value', ana));
    });

    test('token expirado: apaga o token salvo', () async {
      when(storage.read).thenAnswer((_) async => 'expired');
      when(remote.currentUser).thenThrow(_unauthorized());

      final result = await repository.restoreSession();

      expect(
        result,
        isA<Ok<dynamic>>().having((ok) => ok.value, 'value', null),
      );
      verify(storage.clear).called(1);
    });

    test('servidor fora do ar: mantém o token salvo', () async {
      when(storage.read).thenAnswer((_) async => 'token-1');
      when(remote.currentUser).thenThrow(
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/auth/me'),
          reason: 'offline',
        ),
      );

      final result = await repository.restoreSession();

      expect(
        result,
        isA<Err<dynamic>>().having(
          (err) => err.failure,
          'failure',
          const NetworkFailure(),
        ),
      );
      verifyNever(storage.clear);
    });
  });

  test(
    'AuthRepositoryImpl | logout: apaga o token mesmo se a API falhar',
    () async {
      when(remote.logout).thenThrow(_unauthorized());

      final result = await repository.logout();

      expect(result, isA<Ok<void>>());
      verify(storage.clear).called(1);
    },
  );
}
