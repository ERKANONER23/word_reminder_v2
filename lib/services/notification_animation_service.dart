import 'package:shared_preferences/shared_preferences.dart';

/// Bir yazı efekti tanımı
class NotificationAnimation {
  final String id;   // prefs anahtarı
  final String name; // Ayarlar'da görünen isim
  const NotificationAnimation({required this.id, required this.name});
}

/// 5 efekt: Varsayılan = animasyonsuz (klasik görünüm)
const List<NotificationAnimation> notificationAnimations = [
  NotificationAnimation(id: 'default', name: 'Yok'),
  NotificationAnimation(id: 'fade', name: 'Solma'),
  NotificationAnimation(id: 'pop', name: 'Pop'),
  NotificationAnimation(id: 'typewriter', name: 'Daktilo'),
  NotificationAnimation(id: 'slide', name: 'Kayma'),
];

/// Seçilen efekti okur/yazar (kalıcı)
class NotificationAnimationService {
  static const String _key = 'notification_animation';

  static Future<String> getAnimation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_key) ?? 'default';
      return notificationAnimations.any((a) => a.id == id)
          ? id
          : 'default';
    } catch (_) {
      return 'default';
    }
  }

  static Future<void> setAnimation(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, id);
    } catch (_) {}
  }
}