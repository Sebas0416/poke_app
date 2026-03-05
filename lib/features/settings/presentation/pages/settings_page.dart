import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:poke_app/core/providers/theme_provider.dart';
import 'package:poke_app/core/router/app_router.dart';
import 'package:poke_app/core/widgets/gradient_background.dart';
import 'package:poke_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:poke_app/features/settings/presentation/widgets/color_picker_row.dart';
import 'package:poke_app/features/settings/presentation/widgets/profile_header.dart';
import 'package:poke_app/features/settings/presentation/widgets/settings_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  String _version = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _loadVersion();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
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
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version} (${info.buildNumber})');
    }
  }

  Future<void> _onSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro que quieres salir?',
          style: TextStyle(color: Colors.white.withAlpha(153)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white.withAlpha(153)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        const Text(
                          'Perfil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          if (user != null) ProfileHeader(user: user),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'PREFERENCIAS',
                              style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SettingsTile(
                            icon: isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            title: 'Tema',
                            subtitle: isDark ? 'Oscuro' : 'Claro',
                            iconColor:
                                isDark ? Colors.deepPurple : Colors.orange,
                            trailing: Switch(
                              value: isDark,
                              onChanged: (_) =>
                                  ref.read(themeModeProvider.notifier).toggle(),
                              activeThumbColor: const Color(0xFFE94560),
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.palette_outlined,
                            title: 'Color de acento',
                            subtitle: 'Personaliza los colores de la app',
                            iconColor: ref.watch(themeColorProvider),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: const ColorPickerRow(),
                          ),
                          const SizedBox(height: 12),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'INFORMACIÓN',
                              style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SettingsTile(
                            icon: Icons.info_outline,
                            title: 'Versión de la app',
                            subtitle: _version.isEmpty ? '...' : _version,
                            iconColor: Colors.blue,
                          ),
                          SettingsTile(
                            icon: Icons.catching_pokemon,
                            title: 'Datos',
                            subtitle: 'Pokémon API (pokeapi.co)',
                            iconColor: Colors.green,
                          ),
                          const SizedBox(height: 24),
                          SettingsTile(
                            icon: Icons.logout,
                            title: 'Cerrar sesión',
                            iconColor: const Color(0xFFE94560),
                            onTap: _onSignOut,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
