import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_app/core/providers/theme_provider.dart';

class GradientBackground extends ConsumerWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ref.watch(themeColorProvider);

    final darkBase = Color.lerp(const Color(0xFF0A0A1A), primaryColor, 0.15)!;
    final darkMid = Color.lerp(const Color(0xFF111128), primaryColor, 0.25)!;
    final darkEnd = Color.lerp(const Color(0xFF0A0A2E), primaryColor, 0.40)!;

    final lightBase = Color.lerp(const Color(0xFF2C3E8C), primaryColor, 0.5)!;
    final lightMid = Color.lerp(const Color(0xFF3D5A99), primaryColor, 0.5)!;
    final lightEnd = Color.lerp(const Color(0xFF5B7FBF), primaryColor, 0.3)!;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [darkBase, darkMid, darkEnd]
              : [lightBase, lightMid, lightEnd],
        ),
      ),
      child: child,
    );
  }
}
