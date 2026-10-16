import 'package:app_test_e2e/application/auth/auth_form_notifier.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';

class RegisterNotifier extends AuthFormNotifier {
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) => submit(
    () => ref.read(registerUsecaseProvider)(
      name: name,
      email: email,
      password: password,
    ),
  );
}
