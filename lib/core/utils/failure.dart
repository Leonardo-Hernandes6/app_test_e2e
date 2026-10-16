import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
}

final class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure();
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

final class ValidationFailure extends Failure {
  const ValidationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([this.statusCode]);

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}
