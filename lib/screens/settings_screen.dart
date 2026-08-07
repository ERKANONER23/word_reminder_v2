import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_interval_provider.dart';
import '../providers/word_provider.dart';
import '../services/file_helper.dart';
import '../services/notification_service.dart';
import '../services/auto_start_service.dart';

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
  final TextEditingController _customSecondsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAutoStart();
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
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === SÜRE SEÇENEKLERİ ===
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

              // === VERİ YÖNETİMİ ===
              const Text(
                'Veri Yönetimi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Tooltip(
                message: 'Tüm kelimeleri CSV dosyası olarak kaydet',
                child: ListTile(
                  leading: const Icon(Icons.upload_file,
                      color: Colors.deepPurple),
                  title: const Text('Dışa Aktar (CSV)'),
                  subtitle: const Text('Kelimeleri CSV dosyasına kaydet'),
                  trailing: _isExporting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : null,
                  onTap: _isExporting ? null : _handleExport,
                ),
              ),

              Tooltip(
                message: 'CSV dosyasından kelimeleri içe aktar',
                child: ListTile(
                  leading: const Icon(Icons.download, color: Colors.green),
                  title: const Text('İçe Aktar (CSV)'),
                  subtitle: const Text('CSV dosyasından kelimeleri yükle'),
                  trailing: _isImporting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : null,
                  onTap: _isImporting ? null : _handleImport,
                ),
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

              const Divider(height: 32),

              // === TEST BİLDİRİMİ ===
              Tooltip(
                message: 'Örnek bir bildirim gönder',
                child: ListTile(
                  leading: const Icon(Icons.notifications_active_outlined,
                      color: Colors.orange),
                  title: const Text('Test Bildirimi'),
                  subtitle: const Text('Bildirim örneği göster'),
                  onTap: () {
                    NotificationService().showTestNotification();
                    Navigator.pop(context);
                  },
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