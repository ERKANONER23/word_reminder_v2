import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_interval_provider.dart';
import '../providers/word_provider.dart';
import '../services/file_helper.dart';
import '../services/auto_start_service.dart';
import '../services/backup_service.dart';
import '../services/notification_theme_service.dart';
import '../services/notification_size_service.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  bool _isImporting = false;
  bool _isExporting = false;
  bool _autoStart = false;
  bool _autoStartLoading = true;
  bool _backupEnabled = false;
  String? _backupFolder;
  String _notificationThemeId = 'mor';
  String _notificationSizeId = 'orta';
  final TextEditingController _customSecondsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAutoStart();
    _loadTheme();
    _loadSize();
    _loadBackup();
  }

  @override
  void dispose() {
    _customSecondsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAutoStart() async {
    final enabled = await AutoStartService.isEnabled();
    if (mounted) {
      setState(() {
        _autoStart = enabled;
        _autoStartLoading = false;
      });
    }
  }

  Future<void> _loadTheme() async {
    final theme = await NotificationThemeService.getTheme();
    if (mounted) {
      setState(() => _notificationThemeId = theme.id);
    }
  }

  Future<void> _loadSize() async {
    final size = await NotificationSizeService.getSize();
    if (mounted) {
      setState(() => _notificationSizeId = size.id);
    }
  }

  Future<void> _loadBackup() async {
    final enabled = await BackupService.isEnabled();
    final folder = await BackupService.getFolder();
    if (mounted) {
      setState(() {
        _backupEnabled = enabled;
        _backupFolder = folder;
      });
    }
  }

  /// Yedeklerin kaydedileceği klasörü seç
  Future<void> _pickBackupFolder() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;
    await BackupService.setFolder(path);
    if (mounted) {
      setState(() => _backupFolder = path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yedek klasörü: $path')),
      );
    }
  }

  /// Yedeklemenin yapıldığı klasörü Dosya Gezgini'nde aç
  Future<void> _openBackupFolder() async {
    try {
      final folder = await BackupService.getFolder();
      final dir = Directory(folder);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      if (Platform.isWindows) {
        await Process.run('explorer', [folder]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Klasör açılamadı: $e')),
        );
      }
    }
  }

  Future<void> _handleImport() async {
    setState(() => _isImporting = true);
    final result = await FileHelper.importFromCsv();
    if (!mounted) return;
    setState(() => _isImporting = false);
    if (result == null) return;
    ref.read(wordListProvider.notifier).loadWords();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İçe Aktarma Tamamlandı'),
        content: Text(result.summary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    final success = await FileHelper.exportToCsv();
    if (!mounted) return;
    setState(() => _isExporting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'CSV dosyası başarıyla kaydedildi!'
            : 'Dışa aktarma başarısız veya iptal edildi'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final intervalSeconds = ref.watch(globalIntervalProvider);
    return AlertDialog(
      title: const Text('Ayarlar'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === BİLDİRİM SIKLIĞI (KOMPAKT ÇİPLER) ===
              const Text(
                'Bildirim Sıklığı',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCompactPreset('5 dk', 300, intervalSeconds),
                  _buildCompactPreset('15 dk', 900, intervalSeconds),
                  _buildCompactPreset('30 dk', 1800, intervalSeconds),
                  _buildCompactPreset('1 sa', 3600, intervalSeconds),
                ],
              ),
              const SizedBox(height: 8),
              // ÖZEL SÜRE + UYGULA
              // IntrinsicHeight + stretch: buton yüksekliği text alanına
              // OTOMATİK eşitlenir (sabit px yok, daha küçük görünüm)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customSecondsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Özel Süre (saniye)',
                          hintText: 'Örn: 120',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Tooltip(
                      message: 'Girilen saniye değerini uygula',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final value = int.tryParse(_customSecondsCtrl.text);
                          if (value != null && value >= 10) {
                            ref
                                .read(globalIntervalProvider.notifier)
                                .setInterval(value);
                          }
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Uygula'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green,
                          // iç boşluklar azaltıldı (dikey padding yok)
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              // === BİLDİRİM TEMASI (TEK SATIR) ===
              const Text(
                'Bildirim Teması',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: notificationThemes.map((t) {
                  final selected = t.id == _notificationThemeId;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () async {
                          await NotificationThemeService.setTheme(t.id);
                          if (mounted) {
                            setState(() => _notificationThemeId = t.id);
                          }
                        },
                        child: Tooltip(
                          message: t.name,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? Colors.deepPurple
                                    : Colors.grey.withOpacity(0.3),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: t.gradient,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: selected
                                      ? const Center(
                                    child: Icon(Icons.check,
                                        color: Colors.white, size: 14),
                                  )
                                      : null,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  t.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Divider(height: 32),
              // === BİLDİRİM BOYUTU ===
              const Text(
                'Bildirim Boyutu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: notificationSizes.map((s) {
                  final selected = s.id == _notificationSizeId;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () async {
                          await NotificationSizeService.setSize(s.id);
                          if (mounted) {
                            setState(() => _notificationSizeId = s.id);
                          }
                        },
                        child: Tooltip(
                          message: '${s.w.toInt()}x${s.h.toInt()} px',
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.deepPurple.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? Colors.deepPurple
                                    : Colors.grey.withOpacity(0.3),
                                width: selected ? 2.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                s.name,
                                style: TextStyle(
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Divider(height: 32),
              // === VERİ YÖNETİMİ (YAN YANA) ===
              const Text(
                'Veri Yönetimi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: 'Tüm kelimeleri CSV dosyası olarak kaydet',
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _handleExport,
                        icon: _isExporting
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                            : const Icon(Icons.upload_file, size: 18),
                        label: const Text('Dışa Aktar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Tooltip(
                      message: 'CSV dosyasından kelimeleri içe aktar',
                      child: ElevatedButton.icon(
                        onPressed: _isImporting ? null : _handleImport,
                        icon: _isImporting
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                            : const Icon(Icons.download, size: 18),
                        label: const Text('İçe Aktar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              // === OTOMATİK YEDEKLEME ===
              const Text(
                'Otomatik Yedekleme',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.backup_rounded,
                    color: Colors.teal),
                title: const Text('Otomatik Yedek'),
                subtitle: const Text(
                    'Açılışta ve her değişiklikte yedek alır'),
                trailing: Switch(
                  value: _backupEnabled,
                  onChanged: (value) async {
                    await BackupService.setEnabled(value);
                    if (mounted) setState(() => _backupEnabled = value);
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.folder_open, color: Colors.teal),
                title: const Text('Yedek Klasörü'),
                subtitle: Text(
                  _backupFolder ?? 'Klasör seçilmedi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              // YAN YANA: Klasör Seç + Klasörü Aç
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: 'Yedeklerin kaydedileceği klasörü seç',
                      child: ElevatedButton.icon(
                        onPressed: _pickBackupFolder,
                        icon: const Icon(Icons.folder_special, size: 18),
                        label: const Text('Klasör Seç'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Tooltip(
                      message: 'Yedeklemenin yapıldığı klasörü aç',
                      child: ElevatedButton.icon(
                        onPressed: _openBackupFolder,
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Klasörü Aç'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              // === SİSTEM ===
              const Text(
                'Sistem',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Tooltip(
                message: 'Bilgisayar açıldığında uygulamayı otomatik başlat',
                child: ListTile(
                  leading: const Icon(Icons.power_settings_new,
                      color: Colors.deepPurple),
                  title: const Text('Windows ile Başlat'),
                  subtitle:
                  const Text('Bilgisayar açılınca otomatik başlar'),
                  trailing: _autoStartLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Switch(
                    value: _autoStart,
                    onChanged: (value) async {
                      setState(() => _autoStartLoading = true);
                      await AutoStartService.setEnabled(value);
                      final enabled =
                      await AutoStartService.isEnabled();
                      if (mounted) {
                        setState(() {
                          _autoStart = enabled;
                          _autoStartLoading = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  // ==================== KOMPAKT SÜRE ÇİPLERİ ====================
  Widget _buildCompactPreset(String label, int seconds, int current) {
    final selected = current == seconds;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: () {
            ref.read(globalIntervalProvider.notifier).setInterval(seconds);
          },
          child: Tooltip(
            message: 'Bildirimi her $seconds saniyede bir göster',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.deepPurple.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? Colors.deepPurple
                      : Colors.grey.withOpacity(0.3),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}