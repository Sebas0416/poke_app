import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:poke_app/features/auth/data/datasources/cognito_auth_datasource.dart';
import 'package:poke_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:poke_app/features/auth/domain/entities/user_entity.dart';
import 'package:poke_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:poke_app/features/auth/domain/usecases/confirm_usecase.dart';
import 'package:poke_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:poke_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:poke_app/features/auth/domain/usecases/register_usecase.dart';

final authDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => CognitoAuthDatasource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

final confirmSignUpUseCaseProvider = Provider<ConfirmSignUpUseCase>(
  (ref) => ConfirmSignUpUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

final class AuthUnauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthInitial());

  Future<bool> checkSession() async {
    state = AuthLoading();
    final repo = _ref.read(authRepositoryProvider);
    final isSignedIn = await repo.isSignedIn();

    if (isSignedIn) {
      final result = await repo.getCurrentUser();
      result.fold(
        (failure) => state = AuthUnauthenticated(),
        (user) => state =
            user != null ? AuthAuthenticated(user) : AuthUnauthenticated(),
      );
      return isSignedIn;
    } else {
      state = AuthUnauthenticated();
      return false;
    }
  }

  Future<void> signIn(String email, String password) async {
    state = AuthLoading();
    final result = await _ref.read(loginUseCaseProvider).call(
          LoginParams(email: email, password: password),
        );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = AuthLoading();
    final result = await _ref.read(registerUseCaseProvider).call(
          RegisterParams(email: email, password: password, name: name),
        );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = AuthUnauthenticated(),
    );
  }

  Future<void> confirmSignUp(String email, String code) async {
    state = AuthLoading();
    final result = await _ref.read(confirmSignUpUseCaseProvider).call(
          ConfirmParams(email: email, code: code),
        );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = AuthUnauthenticated(),
    );
  }

  Future<void> signOut() async {
    await _ref.read(logoutUseCaseProvider).call();
    state = AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) state = AuthUnauthenticated();
  }
}
