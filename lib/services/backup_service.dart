import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

/// Belirtilen klasöre otomatik CSV yedekleme
/// Varsayılan klasör: exe'nin yanındaki "backup" klasörü
/// Otomatik yedek TEK dosyaya üzerine yazar, adı güncel tarih+saat taşır.
class BackupService {
  static const String _keyEnabled = 'backup_enabled';
  static const String _keyFolder = 'backup_folder';

  // Otomatik yedek dosyaları bu önekle başlar (dışa aktarma "kelimeler_" kullanır, karışmaz)
  static const String _autoPrefix = 'kelime_yedek_';

  // ---------- VARSAYILAN KLASÖR ----------
  /// exe_dizini/backup
  static String get defaultFolder =>
      p.join(p.dirname(Platform.resolvedExecutable), 'backup');

  // ---------- AYARLAR ----------
  /// Otomatik yedek AÇIK mı? (varsayılan: AÇIK)
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
  }

  /// Kayıtlı klasör yoksa VARSAYILAN (exe/backup) döner
  static Future<String> getFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFolder) ?? defaultFolder;
  }

  static Future<void> setFolder(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFolder, path);
  }

  // ---------- TARİH FORMATI ----------
  /// kelime_yedek_2026-08-13_14-30-45.csv
  static String _buildFileName() {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
    return '${_autoPrefix}${date}_$time.csv';
  }

  // ---------- YEDEKLEME ----------
  /// Ayar açıksa yedek alır (sessiz, hatasız çalışır)
  static Future<void> autoBackup() async {
    try {
      final enabled = await isEnabled();
      if (!enabled) return;
      final folder = await getFolder();
      await _writeBackup(folder);
    } catch (e) {
      debugPrint('Otomatik yedek hatası: $e');
    }
  }

  /// TEK dosyaya yazar:
  /// 1) Klasördeki eski otomatik yedekleri (kelime_yedek_*) siler
  ///    → dışa aktarma dosyaları (kelimeler_*) KORUNUR
  /// 2) Yeni güncel tarih+saatli adla yazar
  ///    → kelime_yedek_2026-08-13_14-30-45.csv
  static Future<String> _writeBackup(String folder) async {
    final dir = Directory(folder);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    // Eski otomatik yedekleri temizle (TEK dosya kuralı)
    try {
      for (final f in dir.listSync()) {
        if (f is File) {
          final name = p.basename(f.path);
          if (name.startsWith(_autoPrefix)) {
            f.deleteSync();
          }
        }
      }
    } catch (_) {}

    // Verileri topla
    final words = await DatabaseService.instance.getAllWords();
    final rows = <List<dynamic>>[
      ['english', 'turkish'],
      ...words.map((w) => [w.english, w.turkish]),
    ];
    final csv = const ListToCsvConverter().convert(rows);

    // Güncel tarih+saatli adla yaz
    final path = p.join(folder, _buildFileName());
    await File(path).writeAsString(csv);

    return path;
  }
}