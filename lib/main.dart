import 'dart:convert';
import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:local_notifier/local_notifier.dart';
import 'app_globals.dart';
import 'screens/home_screen.dart';
import 'screens/notification_popup.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/window_listener.dart';
import 'services/tray_service.dart';
import 'services/single_instance_service.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_history_provider.dart';

void main(List<String> args) async {
  // ===== BİLDİRİM POPUP PENCERESİ (ikinci instance) =====
  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.parse(args[1]);
    final controller = WindowController.fromWindowId(windowId);

    Map<String, dynamic> data = {};
    if (args.length > 2) {
      try {
        data = jsonDecode(args[2]) as Map<String, dynamic>;
      } catch (_) {}
    }

    runApp(NotificationPopupApp(controller: controller, data: data));
    return;
  }

  // ===== ANA UYGULAMA =====
  WidgetsFlutterBinding.ensureInitialized();

  // TEK INSTANCE KONTROLÜ
  final isFirstInstance = await SingleInstanceService.ensure();
  if (!isFirstInstance) {
    exit(0);
  }

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  try {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(540, 960),
        center: true,
        title: "Kelime Hatiratici",
        minimumSize: Size(400, 711),
      ),
          () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
    await windowManager.setPreventClose(true);
    windowManager.addListener(MyWindowListener());
  } catch (e) {
    debugPrint('Pencere hatası: $e');
  }

  final container = ProviderContainer();

  NotificationService().onNotificationShown = (english, turkish, index) {
    container
        .read(notificationHistoryProvider.notifier)
        .addNotification(english, turkish, index);
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WordReminderApp(),
    ),
  );

  try {
    await localNotifier.setup(appName: 'Kelime Hatiratici');
  } catch (e) {
    debugPrint('local_notifier hatası: $e');
  }

  try {
    await TrayService().init();
  } catch (e) {
    debugPrint('Tepsi hatası: $e');
  }

  await NotificationService().initialize();
  BackgroundService.startTimer();
}

class WordReminderApp extends ConsumerWidget {
  const WordReminderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Kelime Hatiratici',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeProvider),
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const HomeScreen(),
    );
  }
}