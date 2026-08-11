import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bir bildirim temasının tanımı: id + görünen ad + gradient renkler.
class NotificationTheme {
  final String id;        // prefs'a kaydedilen benzersiz anahtar
  final String name;      // Ayarlar'da görünen isim
  final List<int> colors; // 0xFFRRGGBB formatında iki renk

  const NotificationTheme({
    required this.id,
    required this.name,
    required this.colors,
  });

  /// Renk listesini Flutter'ın LinearGradient'ına çevirir.
  LinearGradient get gradient => LinearGradient(
    colors: colors.map((c) => Color(c)).toList(),
    begin: Alignment.topLeft,     // sol üstten
    end: Alignment.bottomRight,   // sağ alta geçiş
  );
}

/// 6 hazır tema. const: derleme anında sabit, performanslı.
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
  // 🚀 YENİ: Deltafin — koyu lacivert arkaplan + GitHub mavisi vurgu
  NotificationTheme(
      id: 'delta',
      name: 'Delta',
      colors: [0xFF1A2027, 0xFF1F6FEB]),
];

/// Tema tercihini okur/yazar (kalıcı).
class NotificationThemeService {
  static const String _key = 'notification_theme';

  /// Kayıtlı temayı döndürür; yoksa/bozuksa ilk temayı (Mor).
  static Future<NotificationTheme> getTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_key) ?? 'mor';
      return notificationThemes.firstWhere(
            (t) => t.id == id,
        orElse: () => notificationThemes.first, // geçersiz id güvenliği
      );
    } catch (_) {
      return notificationThemes.first;
    }
  }

  /// Seçimi kalıcı olarak kaydeder.
  static Future<void> setTheme(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, id);
    } catch (_) {}
  }
}