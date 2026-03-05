import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

/// Server/API failures
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({String message = 'Error del servidor', this.statusCode})
      : super(message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Local cache/database failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al acceder a datos locales']);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}
