import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_interval_provider.dart';
import '../providers/word_provider.dart';
import '../services/file_helper.dart';
import '../services/auto_start_service.dart';
import '../services/notification_theme_service.dart';

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
  String _notificationThemeId = 'mor';
  final TextEditingController _customSecondsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAutoStart();
    _loadTheme();
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
              // === BİLDİRİM SIKLIĞI ===
              const Text(
                'Bildirim Sıklığı',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildPresetTile('5 Dakika (300 sn)', 300, intervalSeconds),
              _buildPresetTile('15 Dakika (900 sn)', 900, intervalSeconds),
              _buildPresetTile('30 Dakika (1800 sn)', 1800, intervalSeconds),
              _buildPresetTile('1 Saat (3600 sn)', 3600, intervalSeconds),
              const SizedBox(height: 8),
              Row(
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
                    child: ElevatedButton(
                      onPressed: () {
                        final value = int.tryParse(_customSecondsCtrl.text);
                        if (value != null && value >= 10) {
                          ref
                              .read(globalIntervalProvider.notifier)
                              .setInterval(value);
                        }
                      },
                      child: const Text('Uygula'),
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // === BİLDİRİM TEMASI ===
              const Text(
                'Bildirim Teması',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: notificationThemes.map((t) {
                  final selected = t.id == _notificationThemeId;
                  return GestureDetector(
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
                        width: 68,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Colors.deepPurple
                                : Colors.grey.withOpacity(0.3),
                            width: selected ? 2.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: t.gradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: selected
                                  ? const Center(
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 18),
                              )
                                  : null,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              t.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
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
                  subtitle: const Text('Bilgisayar açılınca otomatik başlar'),
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

  Widget _buildPresetTile(String title, int seconds, int current) {
    return Tooltip(
      message: 'Bildirimi her $seconds saniyede bir göster',
      child: RadioListTile<int>(
        title: Text(title),
        value: seconds,
        groupValue: current,
        onChanged: (v) {
          if (v != null) {
            ref.read(globalIntervalProvider.notifier).setInterval(v);
          }
        },
      ),
    );
  }
}