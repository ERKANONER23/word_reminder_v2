import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import '../services/background_service.dart';
import '../services/single_instance_service.dart';
import '../services/tray_service.dart';

/// Kapatma onay penceresi: onaydan sonra adımlar aynı dialog içinde gösterilir.
class ExitDialog extends StatefulWidget {
  const ExitDialog({super.key});

  @override
  State<ExitDialog> createState() => _ExitDialogState();
}

class _ExitDialogState extends State<ExitDialog> {
  bool _shuttingDown = false;
  int _activeIndex = -1;
  final List<bool> _done = [false, false, false, false];

  static const List<Map<String, dynamic>> _steps = [
    {'title': 'Bildirim zamanlayıcısı durduruluyor', 'icon': Icons.timer_off_outlined},
    {'title': 'Veriler kaydediliyor', 'icon': Icons.save_outlined},
    {'title': 'Sistem tepsisi temizleniyor', 'icon': Icons.task_alt_outlined},
    {'title': 'Uygulama kapatılıyor', 'icon': Icons.power_settings_new},
  ];

  void _setActive(int i) {
    if (mounted) setState(() => _activeIndex = i);
  }

  void _setDone(int i) {
    if (mounted) setState(() => _done[i] = true);
  }

  Future<void> _startShutdown() async {
    setState(() => _shuttingDown = true);

    // 1) Zamanlayıcıyı durdur
    _setActive(0);
    BackgroundService.stopTimer();
    await Future.delayed(const Duration(milliseconds: 500));
    _setDone(0);

    // 2) Verileri kaydet
    _setActive(1);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('clean_shutdown', true);
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));
    _setDone(1);

    // 3) Tepsiyi temizle + PORTU SERBEST BIRAK (hayalet fix)
    _setActive(2);
    await TrayService().destroyTray();
    SingleInstanceService.dispose(); // ← soket kapanır, port boşalır
    await Future.delayed(const Duration(milliseconds: 500));
    _setDone(2);

    // 4) Kapat
    _setActive(3);
    await Future.delayed(const Duration(milliseconds: 400));
    _setDone(3);
    await Future.delayed(const Duration(milliseconds: 300));

    // Tüm temizlik bitti → pencereyi yok et + süreci KESİN sonlandır.
    // exit(0) burada GÜVENLİDİR çünkü tüm kayıtlar zaten tamamlandı;
    // böylece görev yöneticisinde hayalet süreç KALMAZ.
    await windowManager.destroy();
    exit(0);
  }

  Widget _buildStep(int index) {
    final step = _steps[index];
    final done = _done[index];
    final active = _activeIndex == index && !done;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: done
                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                : active
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.deepPurple),
            )
                : const Icon(Icons.radio_button_unchecked,
                color: Colors.grey, size: 18),
          ),
          const SizedBox(width: 12),
          Icon(step['icon'] as IconData,
              color: done ? Colors.green : Colors.grey, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              step['title'] as String,
              style: TextStyle(
                color: done
                    ? Colors.green
                    : (active
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.grey),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Kapanış başladıysa geri tuşunu engelle
      canPop: !_shuttingDown,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.power_settings_new,
                color: _shuttingDown ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(_shuttingDown ? 'Kapatılıyor...' : 'Uygulamayı Kapat'),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: _shuttingDown
              ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lütfen bekleyin, işlemler yapılıyor:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ...List.generate(_steps.length, (i) => _buildStep(i)),
            ],
          )
              : const Text(
            'Uygulama tamamen kapatılacak ve bildirimler duracak.\nEmin misiniz?',
          ),
        ),
        actions: _shuttingDown
            ? [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Kapatılıyor, lütfen bekleyin...',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ]
            : [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _startShutdown,
            child: const Text('Kapat',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}