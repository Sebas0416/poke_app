import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_app/core/router/app_router.dart';
import 'package:poke_app/core/utils/validators.dart';
import 'package:poke_app/core/widgets/gradient_background.dart';
import 'package:poke_app/core/widgets/gradient_button.dart';
import 'package:poke_app/core/widgets/custom_text_field.dart';
import 'package:poke_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:poke_app/features/auth/presentation/widgets/animated_pokeball.dart';
import 'package:poke_app/features/auth/presentation/widgets/email_dialog.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
      if (next is AuthAuthenticated) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            const AnimatedPokeball(size: 100),
                            const SizedBox(height: 16),
                            const Text(
                              'Poke App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Inicia sesión para continuar',
                              style: TextStyle(
                                color: Colors.white.withAlpha(153),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 52),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Correo electrónico',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              icon: Icons.lock_outlined,
                              obscureText: _obscurePassword,
                              validator: Validators.password,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white54,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        28,
                        0,
                        28,
                        MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GradientButton(
                            onPressed: isLoading ? null : _onSubmit,
                            isLoading: isLoading,
                            label: 'Iniciar Sesión',
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿No tienes cuenta?',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(153),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.push(AppRoutes.register),
                                child: const Text(
                                  'Regístrate',
                                  style: TextStyle(
                                    color: Color(0xFFE94560),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () async {
                              final email = _emailController.text.trim();
                              if (Validators.email(email) == null) {
                                context.push(AppRoutes.confirm, extra: email);
                                return;
                              }
                              final emailFromDialog = await showDialog<String>(
                                context: context,
                                builder: (context) => EmailDialog(),
                              );

                              if (emailFromDialog != null && context.mounted) {
                                context.push(AppRoutes.confirm,
                                    extra: emailFromDialog);
                              }
                            },
                            child: Text(
                              '¿Ya tienes un código de verificación?',
                              style: TextStyle(
                                color: Colors.white.withAlpha(102),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
