import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:win32/win32.dart'; // GetForegroundWindow

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

  /// Bildirim açılmadan ÖNCE hangi pencere öndeyse onu kaydet.
  int _captureForeground() {
    try {
      return GetForegroundWindow();
    } catch (_) {
      return 0;
    }
  }

  Future<void> showWordNotification({
    required String english,
    required String turkish,
    int? wordId,
    int? index,
  }) async {
    try {
      // 1) ODAK KAYDI: kullanıcının yazdığı pencereyi hatırla
      final prevHwnd = _captureForeground();

      final title =
          'KH_NOTIFY_${DateTime.now().millisecondsSinceEpoch}';

      await DesktopMultiWindow.createWindow(jsonEncode({
        'english': english,
        'turkish': turkish,
        'index': index,
        'title': title,
        'prevHwnd': prevHwnd, // ← popup odağı geri verecek
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