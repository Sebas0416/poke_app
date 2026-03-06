import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_app/features/auth/presentation/widgets/password_requirements.dart';

void main() {
  Widget buildSubject(String password) {
    return MaterialApp(
      home: Scaffold(
        body: PasswordRequirements(password: password),
      ),
    );
  }

  group('PasswordRequirements', () {
    testWidgets('debe mostrar todos los requisitos', (tester) async {
      await tester.pumpWidget(buildSubject(''));
      expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
      expect(find.text('Una letra mayúscula'), findsOneWidget);
      expect(find.text('Un número'), findsOneWidget);
      expect(find.text('Un carácter especial (!@#\$%)'), findsOneWidget);
    });

    testWidgets('debe mostrar check cuando se cumple longitud mínima',
        (tester) async {
      await tester.pumpWidget(buildSubject('12345678'));
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      final checks =
          icons.where((i) => i.icon == Icons.check_circle_rounded).toList();
      expect(checks.length, greaterThanOrEqualTo(1));
    });

    testWidgets('debe mostrar todos los checks con contraseña válida',
        (tester) async {
      await tester.pumpWidget(buildSubject('Test1234!'));
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      final checks =
          icons.where((i) => i.icon == Icons.check_circle_rounded).toList();
      expect(checks.length, 4);
    });

    testWidgets('debe mostrar cero checks con contraseña vacía',
        (tester) async {
      await tester.pumpWidget(buildSubject(''));
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      final checks =
          icons.where((i) => i.icon == Icons.check_circle_rounded).toList();
      expect(checks.length, 0);
    });
  });
}
