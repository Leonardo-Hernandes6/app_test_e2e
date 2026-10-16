import 'package:flutter/widgets.dart';

abstract final class RegisterKeys {
  static const page = Key('register.page');
  static const name = Key('register.name');
  static const email = Key('register.email');
  static const password = Key('register.password');
  static const passwordConfirmation = Key('register.passwordConfirmation');
  static const submit = Key('register.submit');
  static const error = Key('register.error');
}
