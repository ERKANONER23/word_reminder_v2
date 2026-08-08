import 'dart:convert';
import 'dart:ui';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';

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

  /// HARİCİ bildirim penceresi (SAĞ ALTTA, MİNİMAL)
  Future<void> showWordNotification({
    required String english,
    required String turkish,
    int? wordId,
    int? index,
  }) async {
    try {
      const double w = 430;
      const double h = 150;
      double x = 500;
      double y = 500;

      try {
        final displays = PlatformDispatcher.instance.displays;
        if (displays.isNotEmpty) {
          final display = displays.first;
          final dpr = display.devicePixelRatio;
          x = display.size.width / dpr - w - 16;
          y = display.size.height / dpr - h - 60;
        }
      } catch (_) {}

      final title =
          'KH_NOTIFY_${DateTime.now().millisecondsSinceEpoch}';

      await DesktopMultiWindow.createWindow(jsonEncode({
        'english': english,
        'turkish': turkish,
        'index': index,
        'title': title,
        'x': x,
        'y': y,
        'w': w,
        'h': h,
      }));

      if (onNotificationShown != null) {
        onNotificationShown!(english, turkish, index);
      }
    } catch (e) {
      debugPrint('Bildirim penceresi hatası: $e');
    }
  }

  /// Uygulama gizlenince Windows bildirimi ile bilgi ver
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
}