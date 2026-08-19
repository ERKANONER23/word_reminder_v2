import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/global_interval_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/word_provider.dart';
import '../services/file_helper.dart';
import '../services/auto_start_service.dart';
import '../services/backup_service.dart';
import '../services/notification_theme_service.dart';
import '../services/notification_size_service.dart';
import '../services/notification_animation_service.dart';
import '../services/notification_behavior_service.dart';

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
  String _animationId = 'default';
  int _durationSec = 6;
  int _turkishDelaySec = 0;
  final TextEditingController _customSecondsCtrl = TextEditingController();
  final TextEditingController _durationCustomCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAutoStart();
    _loadTheme();
    _loadSize();
    _loadBackup();
    _loadAnimation();
    _loadBehavior();
  }

  @override
  void dispose() {
    _customSecondsCtrl.dispose();
    _durationCustomCtrl.dispose();
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
    if (mounted) setState(() => _notificationThemeId = theme.id);
  }

  Future<void> _loadSize() async {
    final size = await NotificationSizeService.getSize();
    if (mounted) setState(() => _notificationSizeId = size.id);
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

  Future<void> _loadAnimation() async {
    final id = await NotificationAnimationService.getAnimation();
    if (mounted) setState(() => _animationId = id);
  }

  Future<void> _loadBehavior() async {
    final dur = await NotificationBehaviorService.getDuration();
    final delay = await NotificationBehaviorService.getTurkishDelay();
    if (mounted) {
      setState(() {
        _durationSec = dur;
        _turkishDelaySec = delay;
      });
    }
  }

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

  // ==================== SIFIRLAMA ====================
  void _showResetDialog() {
    final code = 100000 + Random().nextInt(900000);
    final ctrl = TextEditingController();
    bool wrong = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.restore, color: Colors.red),
              SizedBox(width: 8),
              Text('Ayarları Sıfırla'),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tüm ayarlar varsayılan değerlere dönecek. '
                      'Onaylamak için aşağıdaki sayıyı aynen yazın:',
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$code',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) {
                    if (ctrl.text.trim() == '$code') {
                      Navigator.pop(ctx);
                      _resetAllSettings();
                    } else {
                      setDialog(() => wrong = true);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Sayıyı buraya yazın',
                    border: const OutlineInputBorder(),
                    errorText:
                    wrong ? 'Sayı yanlış! Sıfırlama yapılmadı.' : null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (ctrl.text.trim() == '$code') {
                  Navigator.pop(ctx);
                  _resetAllSettings();
                } else {
                  setDialog(() => wrong = true);
                }
              },
              child: const Text('Sıfırla',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    const keys = [
      'theme_mode',
      'global_interval_seconds',
      'notification_theme',
      'notification_size',
      'notification_animation',
      'notification_duration',
      'notification_turkish_delay',
      'backup_enabled',
      'backup_folder',
    ];
    for (final k in keys) {
      await prefs.remove(k);
    }
    ref.read(globalIntervalProvider.notifier).setInterval(300);
    ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
    await AutoStartService.setEnabled(false);
    if (mounted) {
      setState(() {
        _notificationThemeId = 'mor';
        _notificationSizeId = 'orta';
        _animationId = 'default';
        _durationSec = 6;
        _turkishDelaySec = 0;
        _backupEnabled = true;
        _backupFolder = null;
        _autoStart = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Tüm ayarlar varsayılanlara döndürüldü')),
      );
    }
  }

  // ==================== RENKLİ BÖLÜM KARTI ====================
  Widget _sectionCard(Color color, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: child,
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
              // === 1) BİLDİRİM ARALIĞI (MOR) ===
              _sectionCard(
                Colors.deepPurple,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bildirim Aralığı ($intervalSeconds sn)',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _chip('5 dk', intervalSeconds == 300, () {
                          ref
                              .read(globalIntervalProvider.notifier)
                              .setInterval(300);
                        }),
                        _chip('15 dk', intervalSeconds == 900, () {
                          ref
                              .read(globalIntervalProvider.notifier)
                              .setInterval(900);
                        }),
                        _chip('30 dk', intervalSeconds == 1800, () {
                          ref
                              .read(globalIntervalProvider.notifier)
                              .setInterval(1800);
                        }),
                        _chip('1 sa', intervalSeconds == 3600, () {
                          ref
                              .read(globalIntervalProvider.notifier)
                              .setInterval(3600);
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Girilen saniye değerini uygula',
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final value =
                                int.tryParse(_customSecondsCtrl.text);
                                if (value != null && value >= 10) {
                                  ref
                                      .read(globalIntervalProvider.notifier)
                                      .setInterval(value);
                                }
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Uygula'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.green,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // === 2) EKRANDA KALMA SÜRESİ (MAVİ) ===
              _sectionCard(
                Colors.blue,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bildirimin Ekranda Kalma Süresi (${_durationSec.toInt()} sn)',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [10, 15, 20, 25, 30].map((s) {
                        return _chip('$s sn', _durationSec.toInt() == s,
                                () async {
                              await NotificationBehaviorService.setDuration(s);
                              if (mounted) setState(() => _durationSec = s);
                            });
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _durationCustomCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Özel Süre (saniye)',
                                hintText: 'Örn: 8',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Girilen saniye değerini uygula',
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final value =
                                int.tryParse(_durationCustomCtrl.text);
                                if (value != null &&
                                    value >= 2 &&
                                    value <= 60) {
                                  NotificationBehaviorService.setDuration(
                                      value);
                                  if (mounted) {
                                    setState(() => _durationSec = value);
                                  }
                                }
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Uygula'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.green,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // === 3) TÜRKÇE GECİKME (TURUNCU) ===
              _sectionCard(
                Colors.orange,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Türkçe Anlam Gecikmesi (${_turkishDelaySec.toInt()} sn)',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [0, 3, 5, 8].map((s) {
                        return _chip(
                            s == 0 ? 'Aynı anda' : '$s sn',
                            _turkishDelaySec.toInt() == s, () async {
                          await NotificationBehaviorService.setTurkishDelay(s);
                          if (mounted) setState(() => _turkishDelaySec = s);
                        });
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // === 4) YAZI EFEKTİ (PEMBE) ===
              _sectionCard(
                Colors.pink,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yazı Efekti',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: notificationAnimations.map((a) {
                        return _chip(a.name, _animationId == a.id, () async {
                          await NotificationAnimationService.setAnimation(a.id);
                          if (mounted) setState(() => _animationId = a.id);
                        }, fontSize: 11);
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // === 5) BİLDİRİM TEMASI (TEAL) ===
              _sectionCard(
                Colors.teal,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bildirim Teması',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
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
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        child: selected
                                            ? const Center(
                                          child: Icon(Icons.check,
                                              color: Colors.white,
                                              size: 14),
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
                  ],
                ),
              ),

              // === 6) BİLDİRİM BOYUTU (YEŞİL) ===
              _sectionCard(
                Colors.green,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bildirim Boyutu',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: notificationSizes.map((s) {
                        return _chip(s.name, _notificationSizeId == s.id,
                                () async {
                              await NotificationSizeService.setSize(s.id);
                              if (mounted) setState(() => _notificationSizeId = s.id);
                            });
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // === 7) VERİ YÖNETİMİ (İNDİGO) ===
              _sectionCard(
                Colors.indigo,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Veri Yönetimi',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
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
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
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
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // === 8) OTOMATİK YEDEKLEME (CYAN) ===
              _sectionCard(
                Colors.cyan,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Otomatik Yedekleme',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
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
                      leading: const Icon(Icons.folder_open,
                          color: Colors.teal),
                      title: const Text('Yedek Klasörü'),
                      subtitle: Text(
                        _backupFolder ?? 'Klasör seçilmedi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
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
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // === 9) SİSTEM (GRİ-MAVİ) ===
              _sectionCard(
                Colors.blueGrey,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sistem',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Tooltip(
                      message: 'Bilgisayar açıldığında uygulamayı otomatik başlat',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
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

              // === 10) SIFIRLA (KIRMIZI) ===
              _sectionCard(
                Colors.red,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showResetDialog,
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Ayarları Sıfırla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.15),
                      foregroundColor: Colors.red,
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

  // ==================== ÇİP ÜRETİCİSİ ====================
  Widget _chip(String label, bool selected, VoidCallback onTap,
      {double fontSize = 12}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: onTap,
          child: Tooltip(
            message: label,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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