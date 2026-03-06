String translateError(String message) {
  const translations = {
    'incorrect username or password': 'Correo o contraseña incorrectos',
    'user does not exist': 'No existe una cuenta con este correo',
    'user is not confirmed': 'Confirma tu correo antes de ingresar',
    'username already exists': 'Ya existe una cuenta con este correo',
    'invalid verification code': 'El código de verificación es incorrecto',
    'invalid code provided': 'El código de verificación es incorrecto',
    'attempt limit exceeded': 'Demasiados intentos, espera un momento',
    'network error': 'Sin conexión a internet',
    'password did not conform':
        'La contraseña no cumple los requisitos de seguridad',
    'password not long enough': 'La contraseña debe tener mínimo 8 caracteres',
  };

  final lower = message.toLowerCase();
  for (final entry in translations.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }

  return 'Ocurrió un error inesperado, intenta de nuevo';
}
