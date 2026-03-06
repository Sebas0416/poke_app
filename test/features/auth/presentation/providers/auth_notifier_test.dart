import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/auth/domain/entities/user_entity.dart';
import 'package:poke_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:poke_app/features/auth/presentation/providers/auth_provider.dart';

import 'auth_notifier_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  const tUser = UserEntity(id: '1', email: 'ash@pokemon.com', name: 'Ash');

  setUp(() {
    mockRepository = MockAuthRepository();
    when(mockRepository.isSignedIn()).thenAnswer((_) async => false);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AuthNotifier', () {
    test('estado inicial debe ser AuthInitial', () {
      final state = container.read(authProvider);
      expect(state, isA<AuthInitial>());
    });

    test('checkSession debe retornar AuthUnauthenticated si no hay sesión',
        () async {
      when(mockRepository.isSignedIn()).thenAnswer((_) async => false);

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state, isA<AuthUnauthenticated>());
    });

    test('checkSession debe retornar AuthAuthenticated si hay sesión activa',
        () async {
      when(mockRepository.isSignedIn()).thenAnswer((_) async => true);
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(tUser));

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user.email, 'ash@pokemon.com');
    });

    test('signIn exitoso debe cambiar estado a AuthAuthenticated', () async {
      when(mockRepository.signIn(
        email: 'ash@pokemon.com',
        password: 'Test1234!',
      )).thenAnswer((_) async => const Right(tUser));

      await container.read(authProvider.notifier).signIn(
            'ash@pokemon.com',
            'Test1234!',
          );

      final state = container.read(authProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user.name, 'Ash');
    });

    test('signIn fallido debe cambiar estado a AuthError', () async {
      when(mockRepository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer(
        (_) async => const Left(AuthFailure('Correo o contraseña incorrectos')),
      );

      await container.read(authProvider.notifier).signIn(
            'wrong@email.com',
            'wrongpass',
          );

      final state = container.read(authProvider);
      expect(state, isA<AuthError>());
      expect(
        (state as AuthError).message,
        'Correo o contraseña incorrectos',
      );
    });

    test('clearError debe cambiar AuthError a AuthUnauthenticated', () async {
      when(mockRepository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer(
        (_) async => const Left(AuthFailure('Error')),
      );

      await container.read(authProvider.notifier).signIn('a@b.com', '123');
      expect(container.read(authProvider), isA<AuthError>());

      container.read(authProvider.notifier).clearError();
      expect(container.read(authProvider), isA<AuthUnauthenticated>());
    });

    test('signOut debe cambiar estado a AuthUnauthenticated', () async {
      when(mockRepository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Right(tUser));
      when(mockRepository.signOut()).thenAnswer((_) async => const Right(null));

      await container.read(authProvider.notifier).signIn(
            'ash@pokemon.com',
            'Test1234!',
          );
      expect(container.read(authProvider), isA<AuthAuthenticated>());

      await container.read(authProvider.notifier).signOut();
      expect(container.read(authProvider), isA<AuthUnauthenticated>());
    });

    test('signUp exitoso debe cambiar estado a AuthUnauthenticated', () async {
      when(mockRepository.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => const Right(null));

      await container.read(authProvider.notifier).signUp(
            'ash@pokemon.com',
            'Test1234!',
            'Ash',
          );

      final state = container.read(authProvider);
      expect(state, isA<AuthUnauthenticated>());
    });
  });
}
