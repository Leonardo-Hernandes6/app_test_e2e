import 'package:app_test_e2e/presentation/pages/register/register_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import 'robot.dart';

class RegisterRobot extends Robot {
  const RegisterRobot(super.tester);

  Future<void> expectVisible() => waitFor(find.byKey(RegisterKeys.page));

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await type(RegisterKeys.name, name);
    await type(RegisterKeys.email, email);
    await type(RegisterKeys.password, password);
    await type(RegisterKeys.passwordConfirmation, password);
    await tap(find.byKey(RegisterKeys.submit));
  }

  Future<void> expectError(String message) => waitFor(
    find.descendant(
      of: find.byKey(RegisterKeys.error),
      matching: find.text(message),
    ),
  );
}
