import 'package:shared_preferences/shared_preferences.dart';

/// Bildirim ve ekleme istatistiklerini yerel olarak tutar.
class StatsService {
  static const _keyTotalShown = 'stats_total_shown';
  static const _keyTodayShown = 'stats_today_shown';
  static const _keyTodayDate = 'stats_today_date';
  static const _keyTotalAdded = 'stats_total_added';
  static const _keyTodayAdded = 'stats_today_added';

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// Gün değiştiyse günlük sayaçları sıfırlar
  static Future<void> _rollDayIfNeeded(SharedPreferences prefs) async {
    final today = _todayStr();
    final saved = prefs.getString(_keyTodayDate);
    if (saved != today) {
      await prefs.setString(_keyTodayDate, today);
      await prefs.setInt(_keyTodayShown, 0);
      await prefs.setInt(_keyTodayAdded, 0);
    }
  }

  static Future<void> recordNotificationShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _rollDayIfNeeded(prefs);
      final total = (prefs.getInt(_keyTotalShown) ?? 0) + 1;
      final today = (prefs.getInt(_keyTodayShown) ?? 0) + 1;
      await prefs.setInt(_keyTotalShown, total);
      await prefs.setInt(_keyTodayShown, today);
    } catch (_) {}
  }

  static Future<void> recordWordAdded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _rollDayIfNeeded(prefs);
      final total = (prefs.getInt(_keyTotalAdded) ?? 0) + 1;
      final today = (prefs.getInt(_keyTodayAdded) ?? 0) + 1;
      await prefs.setInt(_keyTotalAdded, total);
      await prefs.setInt(_keyTodayAdded, today);
    } catch (_) {}
  }

  static Future<StatsSnapshot> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _rollDayIfNeeded(prefs);
      return StatsSnapshot(
        totalShown: prefs.getInt(_keyTotalShown) ?? 0,
        todayShown: prefs.getInt(_keyTodayShown) ?? 0,
        totalAdded: prefs.getInt(_keyTotalAdded) ?? 0,
        todayAdded: prefs.getInt(_keyTodayAdded) ?? 0,
      );
    } catch (_) {
      return const StatsSnapshot();
    }
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTotalShown);
    await prefs.remove(_keyTodayShown);
    await prefs.remove(_keyTodayDate);
    await prefs.remove(_keyTotalAdded);
    await prefs.remove(_keyTodayAdded);
  }
}

class StatsSnapshot {
  final int totalShown;
  final int todayShown;
  final int totalAdded;
  final int todayAdded;

  const StatsSnapshot({
    this.totalShown = 0,
    this.todayShown = 0,
    this.totalAdded = 0,
    this.todayAdded = 0,
  });
}
