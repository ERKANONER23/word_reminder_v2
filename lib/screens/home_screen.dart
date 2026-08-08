import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../models/word_model.dart';
import '../providers/word_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/global_interval_provider.dart';
import '../providers/notification_history_provider.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';
import 'shutdown_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _capitalize(String text) => text.isEmpty
      ? text
      : text[0].toUpperCase() + text.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordListProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final history = ref.watch(notificationHistoryProvider);
    final intervalSeconds = ref.watch(globalIntervalProvider);

    // Son eklenen 5 kelime
    final recentWords = words.reversed.take(5).toList();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () =>
            _showAddDialog(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Kelime Hatiratici'),
            // ===== SOL: GİZLE / KAPAT =====
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Uygulamayı Gizle',
                  icon: const Icon(Icons.visibility_off_outlined),
                  onPressed: _hideApp,
                ),
                IconButton(
                  tooltip: 'Uygulamayı Kapat',
                  icon: const Icon(Icons.power_settings_new),
                  onPressed: () => _showExitDialog(context),
                ),
              ],
            ),
            leadingWidth: 100,
            actions: [
              // KOYU MOD
              Center(
                child: Tooltip(
                  message: isDark ? 'Açık moda geç' : 'Koyu moda geç',
                  child: Switch(
                    value: isDark,
                    onChanged: (_) =>
                        ref.read(themeProvider.notifier).toggleTheme(),
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Icon(Icons.dark_mode, size: 14);
                        }
                        return const Icon(Icons.light_mode, size: 14);
                      },
                    ),
                  ),
                ),
              ),
              // SÜRE
              Center(
                child: Tooltip(
                  message:
                  'Bildirim süresini ayarla (şu an: $intervalSeconds sn)',
                  child: GestureDetector(
                    onTap: () => _showIntervalDialog(context),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color:
                        Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$intervalSeconds sn',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // AYARLAR
              IconButton(
                tooltip: 'Ayarlar',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => const SettingsDialog(),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ===== SON BİLDİRİMLER =====
                if (history.isNotEmpty)
                  _buildNotificationCard(context, history),

                // ===== SON EKLENEN KELİMELER =====
                if (recentWords.isNotEmpty)
                  _buildRecentWordsCard(
                      context, recentWords, words.length, isDark),

                // ===== BOŞ DURUM =====
                if (words.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.book_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz kelime eklenmedi.\nYeni kelime eklemek için + butonuna basın\nveya Enter tuşuna basın.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // ===== ALT BUTONLAR =====
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.delete_outline,
                    label: 'Kelime Sil',
                    color: Colors.red,
                    tooltip: 'Listeden bir kelime sil',
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.edit_outlined,
                    label: 'Kelime Düzenle',
                    color: Colors.blue,
                    tooltip: 'Index veya kelime ile düzenle',
                    onPressed: () => _showEditLookupDialog(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.add,
                    label: 'Kelime Ekle',
                    color: Colors.deepPurple,
                    tooltip: 'Yeni kelime ekle (Enter tuşu da çalışır)',
                    onPressed: () => _showAddDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== ALT BUTON ÜRETİCİSİ ====================
  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Tooltip(
        message: tooltip ?? label,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ==================== GİZLE ====================
  Future<void> _hideApp() async {
    await windowManager.hide();
    NotificationService().showBackgroundInfoNotification();
  }

  // ==================== KAPAT ====================
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ExitDialog(),
    );
  }

  // ==================== SON BİLDİRİMLER KARTI ====================
  Widget _buildNotificationCard(
      BuildContext context, List<Map<String, dynamic>> history) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
            Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ORTALI BAŞLIK
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Son Bildirimler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...history.asMap().entries.map((entry) {
            final n = entry.value;
            final isFirst = entry.key == 0;
            return Tooltip(
              message: 'Düzenlemek için tıklayın',
              child: GestureDetector(
                onTap: () => _editFromHistory(n),
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: entry.key < history.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withOpacity(isFirst ? 0.9 : 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: isFirst
                        ? Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4),
                      width: 1.5,
                    )
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Index rozeti
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${n['index'] ?? '?'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // İKİ EŞİT SÜTUN (ORTALI)
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                _capitalize(n['english']),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: 28,
                              margin:
                              const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.25),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _capitalize(n['turkish']),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SABİT slot
                      SizedBox(
                        width: 48,
                        child: isFirst
                            ? Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                              Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Yeni',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                            : const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Bildirim satırına tıklayınca düzenleme açar
  void _editFromHistory(Map<String, dynamic> n) {
    final english = (n['english'] ?? '').toString();
    final words = ref.read(wordListProvider);

    Word? word;
    for (final w in words) {
      if (w.english.toLowerCase() == english.toLowerCase()) {
        word = w;
        break;
      }
    }

    if (word == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$english" listede bulunamadı')),
      );
      return;
    }

    _showEditFormDialog(context, word);
  }

  // ==================== SON EKLENEN KELİMELER KARTI ====================
  // ==================== SON EKLENEN KELİMELER KARTI ====================
  Widget _buildRecentWordsCard(BuildContext context, List<Word> recentWords,
      int totalWords, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(isDark ? 0.15 : 0.35),
            Colors.orange.withOpacity(isDark ? 0.08 : 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(isDark ? 0.3 : 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TAM GENİŞLİK -> başlık ortalanır, rozet sağda kalır
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ORTALI BAŞLIK
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fiber_new_rounded,
                      color: isDark
                          ? Colors.amber.shade300
                          : Colors.orange.shade800,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Son Eklenen Kelimeler',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isDark
                            ? Colors.amber.shade300
                            : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                // SAĞDA TOPLAM ROZETİ
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.shade700
                            : Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Toplam: $totalWords',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...recentWords.asMap().entries.map((entry) {
            final word = entry.value;
            final isFirst = entry.key == 0;
            final realIndex = totalWords - entry.key;

            return Tooltip(
              message: 'Düzenlemek için tıklayın',
              child: GestureDetector(
                onTap: () => _showEditFormDialog(context, word),
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: entry.key < recentWords.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withOpacity(isFirst ? 0.9 : 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: isFirst
                        ? Border.all(
                      color:
                      Colors.amber.withOpacity(isDark ? 0.5 : 0.6),
                      width: 1.5,
                    )
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Index rozeti
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade600,
                              Colors.amber.shade600,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$realIndex',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // İKİ EŞİT SÜTUN (ORTALI)
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                _capitalize(word.english),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: 28,
                              margin:
                              const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.25),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _capitalize(word.turkish),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SABİT slot
                      SizedBox(
                        width: 48,
                        child: isFirst
                            ? Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Yeni',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                            : const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  // ==================== SÜRE DIALOGU ====================
  void _showIntervalDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final currentInterval = ref.read(globalIntervalProvider);
    ctrl.text = currentInterval.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bildirim Süresi'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Süre (saniye)',
            hintText: 'Örn: 300',
            prefixIcon: Icon(Icons.timer),
          ),
          onSubmitted: (value) {
            final seconds = int.tryParse(value);
            if (seconds != null && seconds >= 10) {
              ref.read(globalIntervalProvider.notifier).setInterval(seconds);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Süre: $seconds saniye ayarlandı')),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final seconds = int.tryParse(ctrl.text);
              if (seconds != null && seconds >= 10) {
                ref
                    .read(globalIntervalProvider.notifier)
                    .setInterval(seconds);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Süre: $seconds saniye ayarlandı')),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  // ==================== EKLEME DIALOGU ====================
  void _showAddDialog(BuildContext context) {
    final englishCtrl = TextEditingController();
    final turkishCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(ctx),
        },
        child: AlertDialog(
          title: const Text('Yeni Kelime Ekle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: englishCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'İngilizce Kelime',
                    hintText: 'Örn: Apple',
                    prefixIcon: Icon(Icons.language),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir kelime girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: turkishCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Türkçe Anlamı',
                    hintText: 'Örn: Elma',
                    prefixIcon: Icon(Icons.translate),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen anlamını girin';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _checkAndSaveWord(
                      context, formKey, englishCtrl, turkishCtrl),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => _checkAndSaveWord(
                  context, formKey, englishCtrl, turkishCtrl),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAndSaveWord(
      BuildContext context,
      GlobalKey<FormState> formKey,
      TextEditingController englishCtrl,
      TextEditingController turkishCtrl,
      ) async {
    if (!formKey.currentState!.validate()) return;

    final english = englishCtrl.text.trim();
    final turkish = turkishCtrl.text.trim();

    final existing =
    await DatabaseService.instance.findWordByEnglish(english);

    if (existing != null && context.mounted) {
      Navigator.pop(context);
      _showDuplicateConfirmDialog(context, english, turkish);
      return;
    }

    _saveWord(context, english, turkish);
  }

  void _showDuplicateConfirmDialog(
      BuildContext context,
      String english,
      String turkish,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kelime Zaten Var'),
        content: Text(
          '"${_capitalize(english)}" kelimesi zaten listede bulunuyor.\n\nYine de eklemek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hayır'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveWord(context, english, turkish);
            },
            child: const Text('Evet, Ekle'),
          ),
        ],
      ),
    );
  }

  void _saveWord(BuildContext context, String english, String turkish) {
    ref.read(wordListProvider.notifier).addWord(english, turkish);
    if (Navigator.canPop(context)) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${_capitalize(english)}" eklendi!')),
    );
  }

  // ==================== DÜZENLEME: INDEX/KELİME GİRİŞİ ====================
  void _showEditLookupDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(ctx),
        },
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Kelime Düzenle'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Düzenlemek istediğiniz kelimenin index numarasını veya İngilizce kelimeyi yazın:',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Index veya Kelime',
                    hintText: 'Örn: 1 veya Apple',
                    prefixIcon: Icon(Icons.search),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir değer girin';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) =>
                      _openEditForm(ctx, formKey, ctrl.text),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => _openEditForm(ctx, formKey, ctrl.text),
              child: const Text('Düzenle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditForm(BuildContext dialogContext,
      GlobalKey<FormState> formKey, String rawInput) async {
    if (!formKey.currentState!.validate()) return;

    final input = rawInput.trim();
    final index = int.tryParse(input);

    Word? foundWord;

    if (index != null) {
      final allWords = ref.read(wordListProvider);
      if (index > 0 && index <= allWords.length) {
        foundWord = allWords[index - 1];
      }
    } else {
      foundWord = await DatabaseService.instance.findWordByEnglish(input);
    }

    if (foundWord == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$input" bulunamadı')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pop(dialogContext);
      _showEditFormDialog(context, foundWord);
    }
  }

  // ==================== DÜZENLEME FORMU ====================
  void _showEditFormDialog(BuildContext context, Word word) {
    final englishCtrl = TextEditingController(text: word.english);
    final turkishCtrl = TextEditingController(text: word.turkish);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        void save() async {
          if (!formKey.currentState!.validate()) return;
          final english = englishCtrl.text.trim();
          final turkish = turkishCtrl.text.trim();

          await ref.read(wordListProvider.notifier).updateWord(
            Word(id: word.id, english: english, turkish: turkish),
          );

          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('"${_capitalize(english)}" güncellendi')),
            );
          }
        }

        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.pop(ctx),
          },
          child: AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.edit, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Düzenle: ${_capitalize(word.english)}'),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: englishCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'İngilizce Kelime',
                      prefixIcon: Icon(Icons.language),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen bir kelime girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: turkishCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Türkçe Anlamı',
                      prefixIcon: Icon(Icons.translate),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen anlamını girin';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => save(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: save,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== SİLME DIALOGU ====================
  void _showDeleteDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(ctx),
        },
        child: AlertDialog(
          title: const Text('Kelime Sil'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Silmek istediğiniz kelimenin index numarasını veya İngilizce kelimeyi yazın:',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Index veya Kelime',
                    hintText: 'Örn: 1 veya Apple',
                    prefixIcon: Icon(Icons.search),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir değer girin';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) =>
                      _submitDelete(ctx, formKey, ctrl.text),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => _submitDelete(ctx, formKey, ctrl.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
              const Text('Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitDelete(BuildContext dialogContext,
      GlobalKey<FormState> formKey, String rawInput) async {
    if (!formKey.currentState!.validate()) return;

    final input = rawInput.trim();
    final index = int.tryParse(input);

    Word? foundWord;

    if (index != null) {
      final allWords = ref.read(wordListProvider);
      if (index > 0 && index <= allWords.length) {
        foundWord = allWords[index - 1];
      }
    } else {
      foundWord = await DatabaseService.instance.findWordByEnglish(input);
    }

    if (foundWord == null || foundWord.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$input" bulunamadı')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pop(dialogContext);
      _confirmDeleteByWord(context, foundWord.id!, foundWord.english);
    }
  }

  // ==================== SİLME ONAYI ====================
  void _confirmDeleteByWord(
      BuildContext context,
      int id,
      String english,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Onay'),
        content: Text(
          '"${_capitalize(english)}" kelimesini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(wordListProvider.notifier).deleteWord(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('"${_capitalize(english)}" silindi')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}