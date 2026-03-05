import 'package:dartz/dartz.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/auth/data/datasources/cognito_auth_datasource.dart';
import 'package:poke_app/features/auth/domain/entities/user_entity.dart';
import 'package:poke_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _datasource.signIn(email: email, password: password);
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _datasource.signUp(email: email, password: password, name: name);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      await _datasource.confirmSignUp(
        email: email,
        confirmationCode: confirmationCode,
      );
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resendConfirmationCode({
    required String email,
  }) async {
    try {
      await _datasource.resendConfirmationCode(email: email);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _datasource.signOut();
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _datasource.getCurrentUser();
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isSignedIn() => _datasource.isSignedIn();
}
