abstract class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Ingresa un correo válido';
    return null;
  }

  /// Validates Cognito password requirements:
  /// min 8 chars, 1 uppercase, 1 number, 1 special char
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Debe contener al menos un carácter especial';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'El nombre es requerido';
    if (value.length < 2) return 'Mínimo 2 caracteres';
    return null;
  }
}
