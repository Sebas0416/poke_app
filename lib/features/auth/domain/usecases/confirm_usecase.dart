import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/auth/domain/repositories/auth_repository.dart';

class ConfirmSignUpUseCase {
  final AuthRepository _repository;

  const ConfirmSignUpUseCase(this._repository);

  Future<Either<Failure, void>> call(ConfirmParams params) {
    return _repository.confirmSignUp(
      email: params.email,
      confirmationCode: params.code,
    );
  }
}

class ConfirmParams extends Equatable {
  final String email;
  final String code;

  const ConfirmParams({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}
