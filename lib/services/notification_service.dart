import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// UI güncellemesi için callback
  Function(String english, String turkish, int? index)? onNotificationShown;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> showWordNotification({
    required String english,
    required String turkish,
    int? wordId,
    int? index,
  }) async {
    try {
      final capEnglish = _capitalize(english);
      final capTurkish = _capitalize(turkish);
      final title = index != null ? '[$index] $capEnglish' : capEnglish;

      final notification = LocalNotification(
        title: title,
        body: capTurkish,
      );

      await notification.show();

      if (onNotificationShown != null) {
        onNotificationShown!(english, turkish, index);
      }
    } catch (e) {
      debugPrint('Bildirim gösterme hatası: $e');
    }
  }

  /// Uygulama gizlenince "arka planda çalışıyor" bilgisi
  Future<void> showBackgroundInfoNotification() async {
    try {
      final notification = LocalNotification(
        title: 'Kelime Hatiratici',
        body: 'Uygulama arka planda çalışmaya devam ediyor. Sistem tepsisinden tekrar açabilirsiniz.',
      );
      await notification.show();
    } catch (e) {
      debugPrint('Bilgi bildirimi hatası: $e');
    }
  }

  Future<void> showTestNotification() async {
    await showWordNotification(
      english: 'Test',
      turkish: 'Bu bir test bildirimidir',
      index: 1,
    );
  }
}