import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/repositories/auth_repository.dart';

class LogoutUsecase {
  const LogoutUsecase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}
