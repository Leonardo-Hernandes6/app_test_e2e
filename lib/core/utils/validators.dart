abstract final class Validators {
  static const minPasswordLength = 6;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(
    String? value, {
    String message = 'Preencha este campo.',
  }) => (value ?? '').trim().isEmpty ? message : null;

  static String? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Informe seu e-mail.';
    return _emailPattern.hasMatch(email) ? null : 'Informe um e-mail válido.';
  }

  static String? password(String? value) =>
      (value ?? '').length < minPasswordLength
      ? 'A senha deve ter pelo menos $minPasswordLength caracteres.'
      : null;
}
