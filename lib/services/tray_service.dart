import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class TrayService {
  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();

  /// Hem debug hem release'de çalışan ikon yolunu bul
  Future<String?> _getIconPath() async {
    try {
      final execDir = p.dirname(Platform.resolvedExecutable);

      // RELEASE: exe'nin yanındaki data/flutter_assets
      final releasePath = p.join(
          execDir, 'data', 'flutter_assets', 'assets', 'app_icon.ico');
      if (File(releasePath).existsSync()) return releasePath;

      // DEBUG: proje kökü
      final debugPath =
      p.join(Directory.current.path, 'assets', 'app_icon.ico');
      if (File(debugPath).existsSync()) return debugPath;

      return null;
    } catch (e) {
      debugPrint('İkon yolu hatası: $e');
      return null;
    }
  }

  Future<void> init() async {
    try {
      final iconPath = await _getIconPath();

      await _systemTray.initSystemTray(
        title: 'Kelime Hatiratici',
        iconPath: iconPath ?? '',
        toolTip: 'Kelime Hatiratici - Çalışıyor',
      );

      await _menu.buildFrom([
        MenuItemLabel(
          label: 'Uygulamayı Göster',
          onClicked: (_) => _showWindow(),
        ),
        MenuItemLabel(
          label: 'Uygulamayı Gizle',
          onClicked: (_) => _hideWindow(),
        ),
        MenuItemLabel(
          label: 'Çıkış',
          onClicked: (_) => _exitApp(),
        ),
      ]);

      await _systemTray.setContextMenu(_menu);

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          _showWindow();
        } else if (eventName == kSystemTrayEventRightClick) {
          _systemTray.popUpContextMenu();
        }
      });
    } catch (e) {
      // İkon yüklenemezse uygulama YİNE DE açılır, sadece tepsi ikonu olmaz
      debugPrint('Sistem tepsisi başlatılamadı (uygulama çalışmaya devam ediyor): $e');
    }
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _hideWindow() async {
    await windowManager.hide();
  }

  Future<void> _exitApp() async {
    await windowManager.destroy();
  }
}