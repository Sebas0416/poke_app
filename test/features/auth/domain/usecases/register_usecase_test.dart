import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:poke_app/features/auth/domain/usecases/register_usecase.dart';

import 'register_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  const tEmail = 'ash@pokemon.com';
  const tPassword = 'Test1234!';
  const tName = 'Ash Ketchum';

  group('RegisterUseCase', () {
    test('debe completar el registro exitosamente', () async {
      when(mockRepository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      )).thenAnswer((_) async => const Right(null));

      final result = await useCase(
        RegisterParams(email: tEmail, password: tPassword, name: tName),
      );

      expect(result, const Right(null));
      verify(mockRepository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      ));
    });

    test('debe retornar AuthFailure cuando el correo ya existe', () async {
      const failure = AuthFailure('Ya existe una cuenta con este correo');
      when(mockRepository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      )).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        RegisterParams(email: tEmail, password: tPassword, name: tName),
      );

      expect(result, const Left(failure));
    });
  });
}
