import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:poke_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:poke_app/features/auth/presentation/pages/login_page.dart';
import 'package:poke_app/features/auth/presentation/providers/auth_provider.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    when(mockRepository.isSignedIn()).thenAnswer((_) async => false);
  });

  Widget buildSubject() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const Scaffold(body: Text('Register')),
        ),
        GoRoute(
          path: '/confirm',
          builder: (_, __) => const Scaffold(body: Text('Confirm')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('LoginPage', () {
    testWidgets('debe mostrar el título Poke App', (tester) async {
      await pumpLogin(tester);
      expect(find.text('Poke App'), findsOneWidget);
    });

    testWidgets('debe mostrar campo de email', (tester) async {
      await pumpLogin(tester);
      expect(find.text('Correo electrónico'), findsOneWidget);
    });

    testWidgets('debe mostrar campo de contraseña', (tester) async {
      await pumpLogin(tester);
      expect(find.text('Contraseña'), findsOneWidget);
    });

    testWidgets('debe mostrar botón de iniciar sesión', (tester) async {
      await pumpLogin(tester);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('debe mostrar enlace a registro', (tester) async {
      await pumpLogin(tester);
      expect(find.text('Regístrate'), findsOneWidget);
    });

    testWidgets('debe mostrar enlace de verificación', (tester) async {
      await pumpLogin(tester);
      expect(
        find.text('¿Ya tienes un código de verificación?'),
        findsOneWidget,
      );
    });

    testWidgets('debe mostrar error cuando se envía formulario vacío',
        (tester) async {
      await pumpLogin(tester);

      await tester.ensureVisible(find.text('Iniciar Sesión'));
      await tester.tap(find.text('Iniciar Sesión'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });
}
