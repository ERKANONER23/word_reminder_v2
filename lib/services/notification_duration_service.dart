import 'package:shared_preferences/shared_preferences.dart';

/// Bildirim penceresinin ekranda kalma süresi (saniye).
/// Kalıcı olarak saklanır; varsayılan 6 sn.
class NotificationDurationService {
  static const String _key = 'notification_duration_seconds';
  static const int defaultSeconds = 6;
  static const int minSeconds = 2;
  static const int maxSeconds = 60;

  /// Kayıtlı süreyi döndürür (2–60 sn arası güvenliği)
  static Future<int> getDuration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getInt(_key) ?? defaultSeconds;
      return v.clamp(minSeconds, maxSeconds);
    } catch (_) {
      return defaultSeconds;
    }
  }

  /// Süreyi kalıcı olarak kaydeder
  static Future<void> setDuration(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, seconds.clamp(minSeconds, maxSeconds));
    } catch (_) {}
  }
}