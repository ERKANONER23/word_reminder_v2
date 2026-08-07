import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final globalIntervalProvider =
StateNotifierProvider<GlobalIntervalNotifier, int>((ref) {
  return GlobalIntervalNotifier();
});

class GlobalIntervalNotifier extends StateNotifier<int> {
  static const String _key = 'global_interval_seconds';

  // Varsayılan: 300 saniye = 5 dakika
  GlobalIntervalNotifier() : super(300) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_key) ?? 300;
  }

  Future<void> setInterval(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, seconds);
    state = seconds;
  }
}