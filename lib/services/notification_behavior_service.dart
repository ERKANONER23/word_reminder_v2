import 'package:shared_preferences/shared_preferences.dart';

/// Ekranda kalma süresi + Türkçe anlam gecikmesi
class NotificationBehaviorService {
  static const String _keyDuration = 'notification_duration';
  static const String _keyDelay = 'notification_turkish_delay';

  /// Bildirimin ekranda kalma süresi (sn) — varsayılan 6
  static Future<int> getDuration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getInt(_keyDuration) ?? 6).clamp(2, 30);
    } catch (_) {
      return 6;
    }
  }

  static Future<void> setDuration(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyDuration, seconds.clamp(2, 30));
    } catch (_) {}
  }

  /// Türkçe anlamın gecikmesi (sn) — 0 = aynı anda
  static Future<int> getTurkishDelay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getInt(_keyDelay) ?? 0).clamp(0, 10);
    } catch (_) {
      return 0;
    }
  }

  static Future<void> setTurkishDelay(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyDelay, seconds.clamp(0, 10));
    } catch (_) {}
  }
}