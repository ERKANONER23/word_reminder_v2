import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'notification_service.dart';

class MyWindowListener extends WindowListener {
  bool _isResizing = false;

  @override
  void onWindowClose() async {
    // ÖNCE anında gizle, SONRA bildirim göster (hızlı kapanma)
    await windowManager.hide();
    await NotificationService().showBackgroundInfoNotification();
  }

  @override
  void onWindowResize() async {
    if (_isResizing) return;
    _isResizing = true;

    try {
      final size = await windowManager.getSize();

      if (size.width < 360 || size.height < 640) {
        await windowManager.setSize(const Size(360, 640));
        return;
      }

      const targetRatio = 9 / 16;
      final expectedHeight = size.width / targetRatio;

      if ((size.height - expectedHeight).abs() > 2) {
        await windowManager.setSize(Size(size.width, expectedHeight));
      }
    } finally {
      _isResizing = false;
    }
  }

  @override
  void onWindowResized() async {
    final size = await windowManager.getSize();
    const targetRatio = 9 / 16;
    final expectedHeight = size.width / targetRatio;

    if ((size.height - expectedHeight).abs() > 2) {
      await windowManager.setSize(Size(size.width, expectedHeight));
    }
  }
}