import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationHistoryProvider = StateNotifierProvider<
    NotificationHistoryNotifier, List<Map<String, dynamic>>>((ref) {
  return NotificationHistoryNotifier();
});

class NotificationHistoryNotifier
    extends StateNotifier<List<Map<String, dynamic>>> {
  NotificationHistoryNotifier() : super([]) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('notification_history') ?? [];
      state = history
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> addNotification(
      String english, String turkish, int? index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('notification_history') ?? [];

      final now = DateTime.now();
      final entry = jsonEncode({
        'english': english,
        'turkish': turkish,
        'index': index,
        'time': now.toIso8601String(),
      });

      // Zaman bazlı duplicate kontrolü:
      // Son 30 saniye içinde aynı kelime geldiyse ekleme
      final decoded = history
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();

      final isRecentDuplicate = decoded.any((item) {
        if (item['english'] != english) return false;
        try {
          final itemTime = DateTime.parse(item['time']);
          return now.difference(itemTime).inSeconds < 30;
        } catch (_) {
          return false;
        }
      });

      if (isRecentDuplicate) return;

      history.insert(0, entry);
      if (history.length > 3) history.removeLast();
      await prefs.setStringList('notification_history', history);

      await loadHistory();
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
    state = [];
  }
}