import 'package:app_test_e2e/application/auth/auth_form_notifier.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';

class LoginNotifier extends AuthFormNotifier {
  Future<void> login({required String email, required String password}) =>
      submit(
        () => ref.read(loginUsecaseProvider)(email: email, password: password),
      );
}
