import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/user.dart';
import 'package:app_test_e2e/domain/repositories/auth_repository.dart';

class RestoreSessionUsecase {
  const RestoreSessionUsecase(this._repository);

  final AuthRepository _repository;

  Future<Result<User?>> call() => _repository.restoreSession();
}
