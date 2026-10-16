import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/user.dart';
import 'package:app_test_e2e/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  const RegisterUsecase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    required String name,
    required String email,
    required String password,
  }) => _repository.register(
    name: name.trim(),
    email: email.trim().toLowerCase(),
    password: password,
  );
}
