import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:win32/win32.dart';
import 'monitor_service.dart';
import 'notification_size_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

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

  int _captureForeground() {
    try {
      return GetForegroundWindow();
    } catch (_) {
      return 0;
    }
  }

  /// HARİCİ bildirim penceresi — SEÇİLİ MONİTÖRÜN sağ alt köşesinde
  Future<void> showWordNotification({
    required String english,
    required String turkish,
    int? wordId,
    int? index,
  }) async {
    try {
      final prevHwnd = _captureForeground();
      final title = 'KH_NOTIFY_${DateTime.now().millisecondsSinceEpoch}';

      // Konumu ANA uygulamada hesapla (plugin'ler burada garantili çalışır)
      double x = 500;
      double y = 500;
      try {
        final m = await MonitorService.getSelectedMonitor();
        final s = await NotificationSizeService.getSize();
        x = m.right - s.w - 12; // sağdan 12px pay
        y = m.bottom - s.h - 12; // görev çubuğu zaten hariç (visible alan)
      } catch (_) {}

      await DesktopMultiWindow.createWindow(jsonEncode({
        'english': english,
        'turkish': turkish,
        'index': index,
        'title': title,
        'prevHwnd': prevHwnd,
        'x': x,
        'y': y,
      }));
      if (onNotificationShown != null) {
        onNotificationShown!(english, turkish, index);
      }
    } catch (e) {
      debugPrint('Bildirim penceresi hatası: $e');
    }
  }

  Future<void> showBackgroundInfoNotification() async {
    try {
      final notification = LocalNotification(
        title: 'Kelime Hatiratici',
        body: 'Uygulama arka planda çalışmaya devam ediyor. '
            'Sistem tepsisinden tekrar açabilirsiniz.',
      );
      await notification.show();
    } catch (e) {
      debugPrint('Bilgi bildirimi hatası: $e');
    }
  }
}