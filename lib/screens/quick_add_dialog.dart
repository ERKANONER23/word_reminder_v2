import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/word_provider.dart';
import '../services/database_service.dart';
import '../services/stats_service.dart';

/// Global hotkey ile açılan kompakt kelime ekleme penceresi.
/// Enter / Ekle → kaydet · ESC → iptal
class QuickAddDialog extends ConsumerStatefulWidget {
  const QuickAddDialog({super.key});

  static bool isOpen = false;

  @override
  ConsumerState<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends ConsumerState<QuickAddDialog> {
  final _englishCtrl = TextEditingController();
  final _turkishCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _englishFocus = FocusNode();
  final _turkishFocus = FocusNode();
  bool _saving = false;

  String _capitalize(String text) => text.isEmpty
      ? text
      : text[0].toUpperCase() + text.substring(1).toLowerCase();

  @override
  void initState() {
    super.initState();
    QuickAddDialog.isOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _englishFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    QuickAddDialog.isOpen = false;
    _englishCtrl.dispose();
    _turkishCtrl.dispose();
    _englishFocus.dispose();
    _turkishFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final english = _englishCtrl.text.trim();
    final turkish = _turkishCtrl.text.trim();
    setState(() => _saving = true);

    final existing =
    await DatabaseService.instance.findWordByEnglish(english);

    if (!mounted) return;

    if (existing != null) {
      setState(() => _saving = false);
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Kelime Zaten Var'),
          content: Text(
            '"${_capitalize(english)}" listede var.\nYine de eklensin mi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hayır'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Evet, Ekle'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      setState(() => _saving = true);
    }

    await ref.read(wordListProvider.notifier).addWord(english, turkish);
    await StatsService.recordWordAdded();

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${_capitalize(english)}" eklendi!')),
    );
  }

  void _cancel() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _cancel,
      },
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flash_on, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Hızlı Ekle'),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ctrl+Shift+W',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _englishCtrl,
                  focusNode: _englishFocus,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'İngilizce Kelime',
                    hintText: 'Örn: Apple',
                    prefixIcon: Icon(Icons.language),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Kelime girin';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _turkishFocus.requestFocus(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _turkishCtrl,
                  focusNode: _turkishFocus,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Türkçe Anlamı',
                    hintText: 'Örn: Elma',
                    prefixIcon: Icon(Icons.translate),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Anlam girin';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _cancel,
            child: const Text('İptal (ESC)'),
          ),
          ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.add, size: 18),
            label: Text(_saving ? 'Ekleniyor…' : 'Ekle (Enter)'),
          ),
        ],
      ),
    );
  }
}

void showQuickAddDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const QuickAddDialog(),
  );
}