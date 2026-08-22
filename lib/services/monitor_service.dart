import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bir monitörün çalışma alanı (bildirim yerleşimi için)
class MonitorArea {
  final int index;
  final bool isPrimary;
  final double left;
  final double top;
  final double right;
  final double bottom;

  const MonitorArea({
    required this.index,
    required this.isPrimary,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get width => right - left;
  double get height => bottom - top;
}

/// Monitörleri listeler + seçim tercihini saklar
class MonitorService {
  static const String _key = 'notification_monitor_index';

  /// num? -> double GÜVENLİ dönüşüm (null ise fallback)
  static double _d(num? v, double fallback) => v?.toDouble() ?? fallback;

  /// Tüm monitörlerin çalışma alanlarını döndürür
  static Future<List<MonitorArea>> getMonitors() async {
    final list = <MonitorArea>[];
    try {
      final displays = await screenRetriever.getAllDisplays();
      final primary = await screenRetriever.getPrimaryDisplay();
      for (int i = 0; i < displays.length; i++) {
        final d = displays[i];
        // Ölçek (num? olabilir) -> double
        final double scale = _d(d.scaleFactor, 1.0);
        // Konum: visiblePosition yoksa 0,0
        final double px = _d(d.visiblePosition?.dx, 0);
        final double py = _d(d.visiblePosition?.dy, 0);
        // Boyut: önce visibleSize, yoksa size, o da yoksa varsayılan
        double sw = _d(d.visibleSize?.width, 0);
        double sh = _d(d.visibleSize?.height, 0);
        if (sw <= 0) sw = _d(d.size?.width, 1920);
        if (sh <= 0) sh = _d(d.size?.height, 1080);
        list.add(MonitorArea(
          index: i,
          isPrimary: d.id == primary.id,
          left: px * scale,
          top: py * scale,
          right: (px + sw) * scale,
          bottom: (py + sh) * scale,
        ));
      }
    } catch (_) {}
    // Hiç monitör okunamazsa güvenli varsayılan
    if (list.isEmpty) {
      list.add(const MonitorArea(
        index: 0,
        isPrimary: true,
        left: 0,
        top: 0,
        right: 1920,
        bottom: 1080,
      ));
    }
    return list;
  }

  /// Seçili monitör indexi (geçersizse 0 = birincil)
  static Future<int> getSelectedIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idx = prefs.getInt(_key) ?? 0;
      final count = (await getMonitors()).length;
      if (idx < 0 || idx >= count) return 0;
      return idx;
    } catch (_) {
      return 0;
    }
  }

  /// Seçili monitörün çalışma alanı
  static Future<MonitorArea> getSelectedMonitor() async {
    final monitors = await getMonitors();
    final idx = await getSelectedIndex();
    return monitors[idx];
  }

  /// Seçimi kalıcı olarak kaydet
  static Future<void> setSelectedIndex(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, index);
    } catch (_) {}
  }
}