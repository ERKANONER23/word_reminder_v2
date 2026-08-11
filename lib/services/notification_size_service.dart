import 'package:shared_preferences/shared_preferences.dart';

/// Bildirim penceresi boyut seçeneği
class NotificationSize {
  final String id;
  final String name;
  final double w;      // pencere genişliği
  final double h;      // pencere yüksekliği
  final double fontEn; // İngilizce yazı boyutu (BÜYÜTÜLDÜ)
  final double fontTr; // Türkçe yazı boyutu (BÜYÜTÜLDÜ)

  const NotificationSize({
    required this.id,
    required this.name,
    required this.w,
    required this.h,
    required this.fontEn,
    required this.fontTr,
  });
}

/// 3 hazır boyut — yazılar artık pencereyi dolduruyor
const List<NotificationSize> notificationSizes = [
  NotificationSize(
      id: 'kucuk', name: 'Küçük', w: 380, h: 130, fontEn: 120, fontTr: 100),
  NotificationSize(
      id: 'orta', name: 'Orta', w: 430, h: 150, fontEn: 135, fontTr: 120),
  NotificationSize(
      id: 'buyuk', name: 'Büyük', w: 520, h: 190, fontEn: 165, fontTr: 150),
];

class NotificationSizeService {
  static const String _key = 'notification_size';

  /// Kayıtlı boyutu döndürür; yoksa Orta.
  static Future<NotificationSize> getSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_key) ?? 'orta';
      return notificationSizes.firstWhere(
            (s) => s.id == id,
        orElse: () => notificationSizes[1],
      );
    } catch (_) {
      return notificationSizes[1];
    }
  }

  static Future<void> setSize(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, id);
    } catch (_) {}
  }
}