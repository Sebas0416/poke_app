import 'package:flutter/material.dart';
import 'package:poke_app/core/utils/validators.dart';

class EmailDialog extends StatefulWidget {
  const EmailDialog({super.key});

  @override
  State<EmailDialog> createState() => _EmailDialogState();
}

class _EmailDialogState extends State<EmailDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Ingresa tu correo',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          validator: Validators.email,
          decoration: InputDecoration(
            hintText: 'trainer@pokemon.com',
            hintStyle: TextStyle(color: Colors.white.withAlpha(80)),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Colors.white54,
            ),
            filled: true,
            fillColor: Colors.white.withAlpha(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE94560),
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.white.withAlpha(153)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
