import 'package:flutter_test/flutter_test.dart';
import 'package:poke_app/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('debe retornar null para un email válido', () {
      expect(Validators.email('ash@pokemon.com'), isNull);
      expect(Validators.email('trainer@gmail.com'), isNull);
    });

    test('debe retornar error para un email inválido', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('noesuncorreo'), isNotNull);
      expect(Validators.email('falta@'), isNotNull);
      expect(Validators.email('@sindominio.com'), isNotNull);
    });

    test('debe retornar error para null', () {
      expect(Validators.email(null), isNotNull);
    });
  });

  group('Validators.password', () {
    test('debe retornar null para una contraseña válida', () {
      expect(Validators.password('Test1234!'), isNull);
      expect(Validators.password('Secure@99'), isNull);
    });

    test('debe retornar error si tiene menos de 8 caracteres', () {
      expect(Validators.password('Te1!'), isNotNull);
    });

    test('debe retornar error si no tiene mayúscula', () {
      expect(Validators.password('test1234!'), isNotNull);
    });

    test('debe retornar error si no tiene número', () {
      expect(Validators.password('TestTest!'), isNotNull);
    });

    test('debe retornar error si no tiene carácter especial', () {
      expect(Validators.password('Test12345'), isNotNull);
    });
  });

  group('Validators.name', () {
    test('debe retornar null para un nombre válido', () {
      expect(Validators.name('Ash'), isNull);
      expect(Validators.name('Ash Ketchum'), isNull);
    });

    test('debe retornar error para nombre muy corto', () {
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name(''), isNotNull);
    });

    test('debe retornar error para null', () {
      expect(Validators.name(null), isNotNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('debe retornar null cuando las contraseñas coinciden', () {
      expect(Validators.confirmPassword('Test1234!', 'Test1234!'), isNull);
    });

    test('debe retornar error cuando las contraseñas no coinciden', () {
      expect(
        Validators.confirmPassword('Test1234!', 'Diferente1!'),
        isNotNull,
      );
    });
  });
}
