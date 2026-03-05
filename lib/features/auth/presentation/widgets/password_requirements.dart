import 'package:flutter/material.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Column(
        children: [
          _Requirement(
            'Mínimo 8 caracteres',
            password.length >= 8,
          ),
          const SizedBox(height: 6),
          _Requirement(
            'Una letra mayúscula',
            password.contains(RegExp(r'[A-Z]')),
          ),
          const SizedBox(height: 6),
          _Requirement(
            'Un número',
            password.contains(RegExp(r'[0-9]')),
          ),
          const SizedBox(height: 6),
          _Requirement(
            'Un carácter especial (!@#\$%)',
            password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')),
          ),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  final String text;
  final bool met;

  const _Requirement(this.text, this.met);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            key: ValueKey(met),
            size: 16,
            color: met ? const Color(0xFF4CAF50) : Colors.white.withAlpha(77),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: met ? const Color(0xFF4CAF50) : Colors.white.withAlpha(102),
          ),
        ),
      ],
    );
  }
}
