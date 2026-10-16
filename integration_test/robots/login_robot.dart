import 'package:app_test_e2e/presentation/pages/login/login_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import 'robot.dart';

class LoginRobot extends Robot {
  const LoginRobot(super.tester);

  Future<void> expectVisible() => waitFor(find.byKey(LoginKeys.page));

  Future<void> login({required String email, required String password}) async {
    await type(LoginKeys.email, email);
    await type(LoginKeys.password, password);
    await tap(find.byKey(LoginKeys.submit));
  }

  Future<void> openRegister() => tap(find.byKey(LoginKeys.goToRegister));

  Future<void> expectError(String message) => waitFor(
    find.descendant(
      of: find.byKey(LoginKeys.error),
      matching: find.text(message),
    ),
  );
}
