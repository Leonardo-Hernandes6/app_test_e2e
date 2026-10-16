import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> login({required String email, required String password});

  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<User?>> restoreSession();

  Future<Result<void>> logout();
}
