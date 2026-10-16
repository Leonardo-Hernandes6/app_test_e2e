import 'package:app_test_e2e/core/utils/failure.dart';

extension FailureMessage on Failure {
  String get message => switch (this) {
    NetworkFailure() =>
      'Não foi possível conectar ao servidor. Verifique sua conexão.',
    UnauthorizedFailure() => 'Sua sessão expirou. Entre novamente.',
    InvalidCredentialsFailure() => 'E-mail ou senha incorretos.',
    EmailAlreadyInUseFailure() => 'Já existe uma conta com este e-mail.',
    NotFoundFailure() => 'O item não foi encontrado.',
    ValidationFailure(:final message) when message.isNotEmpty => message,
    ValidationFailure() => 'Confira os dados informados.',
    ServerFailure() => 'Algo deu errado. Tente novamente.',
  };
}
