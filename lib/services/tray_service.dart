import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import '../app_globals.dart';
import '../screens/shutdown_screen.dart';
import 'background_service.dart';
import 'single_instance_service.dart';

/// Sistem tepsisi ikonu + sağ tık menüsü (Singleton).
class TrayService {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();

  /// İkon yolunu DEBUG ve RELEASE için akıllıca bulur.
  Future<String?> _getIconPath() async {
    try {
      final execDir = p.dirname(Platform.resolvedExecutable);
      // RELEASE yolu: exe/data/flutter_assets/assets/app_icon.ico
      final releasePath = p.join(
          execDir, 'data', 'flutter_assets', 'assets', 'app_icon.ico');
      if (File(releasePath).existsSync()) return releasePath;
      // DEBUG yolu: proje_kökü/assets/app_icon.ico
      final debugPath = p.join(Directory.current.path, 'assets', 'app_icon.ico');
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
          onClicked: (_) => exitApp(),
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
      debugPrint('Sistem tepsisi başlatılamadı: $e');
    }
  }

  /// Tepsi ikonunu kaldırır (kapanış dialogu kullanır).
  Future<void> destroyTray() async {
    try {
      await _systemTray.destroy();
    } catch (_) {}
  }

  /// TEPSİDEN ÇIKIŞ: pencereyi aç + kapanış adımları dialogunu göster.
  Future<void> exitApp() async {
    // 1) Uygulamayı göster (kullanıcı adımları görsün)
    try {
      await windowManager.show();
      await windowManager.focus();
    } catch (_) {}

    // 2) Kapanış dialogunu aç (navigatorKey ile, context olmadan)
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const ExitDialog(),
      );
    } else {
      // Güvenlik yolu: context yoksa sessiz ama KESİN kapanış
      BackgroundService.stopTimer();
      await destroyTray();
      SingleInstanceService.dispose(); // portu bırak
      await windowManager.destroy();
      exit(0); // hayalet süreç kalmasın
    }
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _hideWindow() async {
    await windowManager.hide();
  }
}