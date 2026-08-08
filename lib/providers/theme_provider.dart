import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider =
StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode';

  // Başlangıçta sistem temasını kullan (kullanıcı tercihi yüklenene kadar)
  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getString(_key);
      if (savedValue == null) {
        state = ThemeMode.system;
      } else if (savedValue == 'dark') {
        state = ThemeMode.dark;
      } else if (savedValue == 'light') {
        state = ThemeMode.light;
      }
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  Future<void> _save(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String value;
      switch (mode) {
        case ThemeMode.dark:
          value = 'dark';
          break;
        case ThemeMode.light:
          value = 'light';
          break;
        case ThemeMode.system:
          value = 'system';
          break;
      }
      await prefs.setString(_key, value);
    } catch (e) {
      // Kaydetme başarısız olursa sessizce geç
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;

  void toggleTheme() {
    final newMode =
    state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    _save(newMode);
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _save(mode);
  }
}