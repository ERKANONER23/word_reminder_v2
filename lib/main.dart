import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:local_notifier/local_notifier.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/window_listener.dart';
import 'services/tray_service.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // 1) ÖNCE PENCERE
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

  // 2) UYGULAMAYI BASLAT
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WordReminderApp(),
    ),
  );

  // 3) SERVISLER (UI'dan sonra)
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