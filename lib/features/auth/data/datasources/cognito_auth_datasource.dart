import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<void> confirmSignUp({
    required String email,
    required String confirmationCode,
  });
  Future<void> resendConfirmationCode({required String email});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isSignedIn();
}

class CognitoAuthDatasource implements AuthRemoteDatasource {
  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      if (!result.isSignedIn) {
        throw const AuthFailure('No se pudo completar el inicio de sesión');
      }

      final user = await getCurrentUser();
      if (user == null) throw const AuthFailure('Usuario no encontrado');
      return user;
    } on AuthNotAuthorizedException {
      throw const AuthFailure('Correo o contraseña incorrectos');
    } on UserNotFoundException {
      throw const AuthFailure('No existe una cuenta con este correo');
    } on UserNotConfirmedException {
      throw const AuthFailure('Confirma tu correo antes de ingresar');
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email,
            AuthUserAttributeKey.name: name,
          },
        ),
      );
    } on UsernameExistsException {
      throw const AuthFailure('Ya existe una cuenta con este correo');
    } on InvalidPasswordException catch (e) {
      throw AuthFailure(e.message);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
    } on CodeMismatchException {
      throw const AuthFailure('El código de verificación es incorrecto');
    } on ExpiredCodeException {
      throw const AuthFailure('El código expiró, solicita uno nuevo');
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> resendConfirmationCode({required String email}) async {
    try {
      await Amplify.Auth.resendSignUpCode(username: email);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();

      final email = attributes
          .firstWhere(
            (a) => a.userAttributeKey == AuthUserAttributeKey.email,
            orElse: () => const AuthUserAttribute(
              userAttributeKey: AuthUserAttributeKey.email,
              value: '',
            ),
          )
          .value;

      final name = attributes
          .firstWhere(
            (a) => a.userAttributeKey == AuthUserAttributeKey.name,
            orElse: () => const AuthUserAttribute(
              userAttributeKey: AuthUserAttributeKey.name,
              value: 'Trainer',
            ),
          )
          .value;

      return UserModel(id: authUser.userId, email: email, name: name);
    } on AuthException {
      return null;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } on AuthException {
      return false;
    }
  }
}
