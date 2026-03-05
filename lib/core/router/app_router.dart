import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_app/features/auth/presentation/pages/confirm_page.dart';
import 'package:poke_app/features/auth/presentation/pages/login_page.dart';
import 'package:poke_app/features/auth/presentation/pages/register_page.dart';
import 'package:poke_app/features/auth/presentation/pages/splash_page.dart';
import 'package:poke_app/features/pokemon/presentation/pages/home_page.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const confirm = '/confirm';
  static const home = '/home';
  static const detail = '/home/pokemon/:id';
  static const settings = '/home/settings';

  static String detailPath(int id) => '/home/pokemon/$id';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.confirm,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: ConfirmPage(email: state.extra as String),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: _fadeTransition,
        ),
        routes: [
          GoRoute(
            path: 'pokemon/:id',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: Scaffold(
                body: Center(
                  child: Text('Detail — próximamente'),
                ),
              ),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const Scaffold(
                body: Center(child: Text('Settings — próximamente')),
              ),
              transitionsBuilder: _slideTransition,
            ),
          ),
        ],
      ),
    ],
  );
});

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
    child: child,
  );
}
