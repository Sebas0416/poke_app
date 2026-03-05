import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ConfirmHeader extends StatelessWidget {
  final String email;

  const ConfirmHeader({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(
          'assets/animations/Pikachu.json',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text(
          'Revisa tu correo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviamos un código de 6 dígitos a',
          style: TextStyle(
            color: Colors.white.withAlpha(153),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
            color: Color(0xFFE94560),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
