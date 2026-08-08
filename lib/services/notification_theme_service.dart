import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTheme {
  final String id;
  final String name;
  final List<int> colors;

  const NotificationTheme({
    required this.id,
    required this.name,
    required this.colors,
  });

  LinearGradient get gradient => LinearGradient(
    colors: colors.map((c) => Color(c)).toList(),
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

const List<NotificationTheme> notificationThemes = [
  NotificationTheme(
      id: 'mor', name: 'Mor', colors: [0xFF6A4BC8, 0xFF8B6FE0]),
  NotificationTheme(
      id: 'gece', name: 'Gece', colors: [0xFF23203A, 0xFF413A63]),
  NotificationTheme(
      id: 'okyanus', name: 'Okyanus', colors: [0xFF0077B6, 0xFF00B4D8]),
  NotificationTheme(
      id: 'gunbatimi',
      name: 'Gün Batımı',
      colors: [0xFFD64570, 0xFFFF8F5A]),
  NotificationTheme(
      id: 'orman', name: 'Orman', colors: [0xFF2D6A4F, 0xFF52B788]),
];

class NotificationThemeService {
  static const String _key = 'notification_theme';

  static Future<NotificationTheme> getTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_key) ?? 'mor';
      return notificationThemes.firstWhere(
            (t) => t.id == id,
        orElse: () => notificationThemes.first,
      );
    } catch (_) {
      return notificationThemes.first;
    }
  }

  static Future<void> setTheme(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, id);
    } catch (_) {}
  }
}