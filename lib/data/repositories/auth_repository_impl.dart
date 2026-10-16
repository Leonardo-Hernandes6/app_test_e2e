import 'package:app_test_e2e/core/utils/error_handler.dart';
import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/data/datasources/auth_remote_datasource.dart';
import 'package:app_test_e2e/data/datasources/secure_storage_datasource.dart';
import 'package:app_test_e2e/data/models/session_model.dart';
import 'package:app_test_e2e/domain/entities/user.dart';
import 'package:app_test_e2e/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDatasource remote,
    required SecureStorageDatasource secureStorage,
  }) : _remote = remote,
       _secureStorage = secureStorage;

  final AuthRemoteDatasource _remote;
  final SecureStorageDatasource _secureStorage;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) => guardRequest(
    () async => _persist(await _remote.login(email: email, password: password)),
  );

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  }) => guardRequest(
    () async => _persist(
      await _remote.register(name: name, email: email, password: password),
    ),
  );

  @override
  Future<Result<User?>> restoreSession() async {
    if (await _secureStorage.read() == null) return const Ok(null);

    final result = await guardRequest(_remote.currentUser);
    switch (result) {
      case Ok(:final value):
        return Ok(value.toEntity());
      case Err(failure: UnauthorizedFailure()):
        await _secureStorage.clear();
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  }

  @override
  Future<Result<void>> logout() async {
    await guardRequest(_remote.logout);
    await _secureStorage.clear();
    return const Ok(null);
  }

  Future<User> _persist(SessionModel session) async {
    await _secureStorage.write(session.token);
    return session.user.toEntity();
  }
}
