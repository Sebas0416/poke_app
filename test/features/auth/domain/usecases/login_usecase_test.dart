import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/auth/domain/entities/user_entity.dart';
import 'package:poke_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:poke_app/features/auth/domain/usecases/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const tEmail = 'ash@pokemon.com';
  const tPassword = 'Test1234!';
  const tUser = UserEntity(id: '1', email: tEmail, name: 'Ash');

  group('LoginUseCase', () {
    test('debe retornar UserEntity cuando el login es exitoso', () async {
      when(mockRepository.signIn(email: tEmail, password: tPassword))
          .thenAnswer((_) async => const Right(tUser));

      final result = await useCase(
        LoginParams(email: tEmail, password: tPassword),
      );

      expect(result, const Right(tUser));
      verify(mockRepository.signIn(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('debe retornar AuthFailure cuando las credenciales son incorrectas',
        () async {
      const failure = AuthFailure('Correo o contraseña incorrectos');
      when(mockRepository.signIn(email: tEmail, password: tPassword))
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        LoginParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
    });

    test('debe retornar AuthFailure cuando el correo no está confirmado',
        () async {
      const failure = AuthFailure('Confirma tu correo antes de ingresar');
      when(mockRepository.signIn(email: tEmail, password: tPassword))
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        LoginParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
    });
  });
}
