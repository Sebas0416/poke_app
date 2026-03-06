import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _themeModeKey = 'theme_mode';
const _themeColorKey = 'theme_color';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await _storage.read(key: _themeModeKey);
    if (saved == 'light') state = ThemeMode.light;
    if (saved == 'dark') state = ThemeMode.dark;
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _storage.write(
      key: _themeModeKey,
      value: state == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

const List<AppColor> appColors = [
  AppColor('Pokémon Rojo', Color(0xFFE94560)),
  AppColor('Azul Agua', Color(0xFF4A90D9)),
  AppColor('Verde Planta', Color(0xFF56C26D)),
  AppColor('Eléctrico', Color(0xFFF7D02C)),
  AppColor('Psíquico', Color(0xFFF95587)),
  AppColor('Dragón', Color(0xFF6F35FC)),
  AppColor('Fuego', Color(0xFFFF6B35)),
  AppColor('Océano', Color(0xFF0F3460)),
];

class AppColor {
  final String name;
  final Color color;
  const AppColor(this.name, this.color);
}

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier, Color>(
  (ref) => ThemeColorNotifier(),
);

class ThemeColorNotifier extends StateNotifier<Color> {
  ThemeColorNotifier() : super(const Color(0xFF0F3460)) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await _storage.read(key: _themeColorKey);
    if (saved != null) {
      state = Color(int.parse(saved));
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    await _storage.write(
      key: _themeColorKey,
      value: color.toARGB32().toString(),
    );
  }
}
