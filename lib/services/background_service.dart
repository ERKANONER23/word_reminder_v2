import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'notification_service.dart';

class BackgroundService {
  static Timer? _timer;

  static void startTimer() {
    _timer?.cancel();

    final db = DatabaseService.instance;
    final notifications = NotificationService();

    // Her 10 saniyede kontrol et
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final words = await db.getAllWords();
      if (words.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final intervalSeconds = prefs.getInt('global_interval_seconds') ?? 300;

      final lastTimeStr = prefs.getString('last_notification_time');
      final lastTime =
      lastTimeStr != null ? DateTime.parse(lastTimeStr) : null;
      final now = DateTime.now();

      if (lastTime == null ||
          now.difference(lastTime).inSeconds >= intervalSeconds) {
        final random = Random();
        final word = words[random.nextInt(words.length)];
        final index = words.indexOf(word) + 1;

        await notifications.showWordNotification(
          english: word.english,
          turkish: word.turkish,
          wordId: word.id,
          index: index,
        );

        await prefs.setString(
            'last_notification_time', now.toIso8601String());
      }
    });
  }

  static void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}