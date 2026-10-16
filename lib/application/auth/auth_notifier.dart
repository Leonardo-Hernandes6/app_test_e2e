import 'package:app_test_e2e/domain/entities/user.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final result = await ref.read(restoreSessionUsecaseProvider)();
    return result.fold(onOk: (user) => user, onErr: (_) => null);
  }

  void signedIn(User user) => state = AsyncData(user);

  Future<void> logout() async {
    await ref.read(logoutUsecaseProvider)();
    state = const AsyncData(null);
  }
}
