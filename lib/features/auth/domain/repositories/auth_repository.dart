import 'package:dartz/dartz.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, void>> confirmSignUp({
    required String email,
    required String confirmationCode,
  });

  Future<Either<Failure, void>> resendConfirmationCode({required String email});

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<bool> isSignedIn();
}
