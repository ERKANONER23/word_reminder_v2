import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

class AutoStartService {
  static bool _initialized = false;

  static Future<void> _init() async {
    if (_initialized) return;

    // setup() void döndürdüğü için await KULLANILMAZ
    launchAtStartup.setup(
      appName: 'Kelime Hatiratici',
      appPath: Platform.resolvedExecutable,
    );

    _initialized = true;
  }

  static Future<bool> isEnabled() async {
    try {
      await _init();
      return await launchAtStartup.isEnabled();
    } catch (e) {
      debugPrint('AutoStart kontrol hatası: $e');
      return false;
    }
  }

  static Future<void> setEnabled(bool enabled) async {
    try {
      await _init();
      if (enabled) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
    } catch (e) {
      debugPrint('AutoStart ayar hatası: $e');
    }
  }
}