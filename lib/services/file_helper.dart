import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';
import '../services/backup_service.dart';

/// CSV içe/dışa aktarma sonuç sınıfı
class ImportResult {
  final int added;
  final int skipped;
  final int failed;
  final List<String> errors;

  ImportResult({
    required this.added,
    required this.skipped,
    required this.failed,
    required this.errors,
  });

  String get summary => 'Eklenen: $added\nAtlanan: $skipped\nHatalı: $failed';
}

class FileHelper {
  // ==================== DIŞA AKTARMA ====================
  /// Varsayılan dizin: backup klasörü
  /// Dosya adı: kelimeler_zaman.csv (otomatik yedekten farklı önek → karışmaz)
  static Future<bool> exportToCsv() async {
    try {
      final words = await DatabaseService.instance.getAllWords();
      if (words.isEmpty) return false;

      List<List<dynamic>> rows = [];
      rows.add(['No', 'English', 'Turkish']);
      for (int i = 0; i < words.length; i++) {
        rows.add([i + 1, words[i].english, words[i].turkish]);
      }
      String csvData = const ListToCsvConverter().convert(rows);

      // Varsayılan dizin: backup klasörü
      final backupFolder = await BackupService.getFolder();

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Kelime Listesini Dışa Aktar',
        fileName:
        'kelimeler_${DateTime.now().millisecondsSinceEpoch}.csv',
        initialDirectory: backupFolder,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        await File(outputFile).writeAsString(csvData, flush: true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Dışa aktarma hatası: $e');
      return false;
    }
  }

  // ==================== İÇE AKTARMA ====================
  static Future<ImportResult?> importFromCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Kelime Listesi Seç (CSV)',
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;
      final filePath = result.files.single.path;
      if (filePath == null) return null;

      final file = File(filePath);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter(
        shouldParseNumbers: false,
        eol: '\n',
      ).convert(content);

      if (rows.isEmpty) {
        return ImportResult(
            added: 0, skipped: 0, failed: 0, errors: ['Dosya boş']);
      }

      int added = 0;
      int skipped = 0;
      int failed = 0;
      List<String> errors = [];

      // Başlık satırını kontrol et
      int startIndex = 0;
      final firstRow = rows[0];
      if (firstRow.length >= 2) {
        final firstCell = firstRow[0].toString().toLowerCase();
        final secondCell = firstRow[1].toString().toLowerCase();
        if (firstCell.contains('no') ||
            firstCell.contains('english') ||
            firstCell.contains('ingilizce') ||
            secondCell.contains('english') ||
            secondCell.contains('ingilizce')) {
          startIndex = 1;
        }
      }

      // Satırları işle
      for (int i = startIndex; i < rows.length; i++) {
        final row = rows[i];
        try {
          if (row.length < 2) {
            failed++;
            errors.add('Satır ${i + 1}: Yetersiz sütun');
            continue;
          }

          String english;
          String turkish;

          if (row.length >= 3) {
            english = row[1].toString().trim();
            turkish = row[2].toString().trim();
          } else {
            english = row[0].toString().trim();
            turkish = row[1].toString().trim();
          }

          if (english.isEmpty || turkish.isEmpty) {
            skipped++;
            continue;
          }

          final existing =
          await DatabaseService.instance.findWordByEnglish(english);
          if (existing != null) {
            skipped++;
            continue;
          }

          await DatabaseService.instance
              .addWord(Word(english: english, turkish: turkish));
          added++;
        } catch (e) {
          failed++;
          errors.add('Satır ${i + 1}: $e');
        }
      }

      return ImportResult(
        added: added,
        skipped: skipped,
        failed: failed,
        errors: errors.take(10).toList(),
      );
    } catch (e) {
      debugPrint('İçe aktarma hatası: $e');
      return ImportResult(
        added: 0,
        skipped: 0,
        failed: 1,
        errors: ['Genel hata: $e'],
      );
    }
  }
}