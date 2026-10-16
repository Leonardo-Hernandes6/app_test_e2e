import 'package:flutter/widgets.dart';

abstract final class LoginKeys {
  static const page = Key('login.page');
  static const email = Key('login.email');
  static const password = Key('login.password');
  static const submit = Key('login.submit');
  static const goToRegister = Key('login.goToRegister');
  static const error = Key('login.error');
}
