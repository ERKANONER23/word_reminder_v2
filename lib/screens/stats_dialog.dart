import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/word_provider.dart';
import '../services/stats_service.dart';

/// İstatistik dialogu — toplam kelime, bugün/toplam bildirim, eklenenler
class StatsDialog extends ConsumerStatefulWidget {
  const StatsDialog({super.key});

  @override
  ConsumerState<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends ConsumerState<StatsDialog> {
  StatsSnapshot _stats = const StatsSnapshot();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await StatsService.load();
    if (mounted) {
      setState(() {
        _stats = s;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordListProvider);
    final totalWords = words.length;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.bar_chart_rounded, color: Colors.teal),
          SizedBox(width: 8),
          Text('İstatistikler'),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: _loading
            ? const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statTile(
              icon: Icons.menu_book_rounded,
              color: Colors.deepPurple,
              label: 'Toplam Kelime',
              value: '$totalWords',
            ),
            const SizedBox(height: 10),
            _statTile(
              icon: Icons.notifications_active_rounded,
              color: Colors.orange,
              label: 'Bugün Gösterilen Bildirim',
              value: '${_stats.todayShown}',
            ),
            const SizedBox(height: 10),
            _statTile(
              icon: Icons.history_rounded,
              color: Colors.blue,
              label: 'Toplam Bildirim',
              value: '${_stats.totalShown}',
            ),
            const SizedBox(height: 10),
            _statTile(
              icon: Icons.add_circle_outline,
              color: Colors.green,
              label: 'Bugün Eklenen',
              value: '${_stats.todayAdded}',
            ),
            const SizedBox(height: 10),
            _statTile(
              icon: Icons.playlist_add_check,
              color: Colors.teal,
              label: 'Toplam Eklenen (kayıtlı)',
              value: '${_stats.totalAdded}',
            ),
            const SizedBox(height: 16),
            Text(
              'Not: “Toplam eklenen” sayacı bu sürümden sonra '
                  'eklenen kelimeleri sayar.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sayaçları Sıfırla'),
                content: const Text(
                  'Bildirim ve ekleme sayaçları sıfırlansın mı?\n'
                      'Kelime listesi silinmez.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Vazgeç'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sıfırla'),
                  ),
                ],
              ),
            );
            if (ok == true) {
              await StatsService.reset();
              await _load();
            }
          },
          child: const Text('Sayaçları Sıfırla'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

void showStatsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const StatsDialog(),
  );
}