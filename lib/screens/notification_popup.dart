import 'dart:ffi';
import 'dart:ui';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import '../services/notification_theme_service.dart';

/// Çerçevesiz + HER ZAMAN ÜSTTE + GÖREV ÇUBUĞUNDA YOK
bool _applyNativeWindowStyle(String title) {
  try {
    final titlePtr = title.toNativeUtf16();
    final hwnd = FindWindow(nullptr, titlePtr);
    free(titlePtr);
    if (hwnd == 0) return false;

    // Başlık çubuğu + çerçeveyi kaldır
    final style = GetWindowLongPtr(hwnd, GWL_STYLE);
    SetWindowLongPtr(
      hwnd,
      GWL_STYLE,
      style & ~WS_CAPTION & ~WS_THICKFRAME,
    );

    // Görev çubuğunda ve Alt-Tab'da GÖSTERME
    final exStyle = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
    SetWindowLongPtr(
      hwnd,
      GWL_EXSTYLE,
      exStyle | WS_EX_TOOLWINDOW,
    );

    // Her zaman üstte
    SetWindowPos(
      hwnd,
      HWND_TOPMOST,
      0,
      0,
      0,
      0,
      SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE,
    );
    return true;
  } catch (_) {
    return false;
  }
}

class NotificationPopupApp extends StatelessWidget {
  final WindowController controller;
  final Map<String, dynamic> data;

  const NotificationPopupApp({
    super.key,
    required this.controller,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: PopupScreen(controller: controller, data: data),
    );
  }
}

class PopupScreen extends StatefulWidget {
  final WindowController controller;
  final Map<String, dynamic> data;

  const PopupScreen({
    super.key,
    required this.controller,
    required this.data,
  });

  @override
  State<PopupScreen> createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  static const Duration _duration = Duration(seconds: 6);

  NotificationTheme _theme = notificationThemes.first;
  bool _shown = false;

  String _capitalize(String text) => text.isEmpty
      ? text
      : text[0].toUpperCase() + text.substring(1).toLowerCase();

  double get _x => _toDouble(widget.data['x'], 500);
  double get _y => _toDouble(widget.data['y'], 500);
  double get _w => _toDouble(widget.data['w'], 430);
  double get _h => _toDouble(widget.data['h'], 150);

  double _toDouble(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  @override
  void initState() {
    super.initState();

    NotificationThemeService.getTheme().then((t) {
      if (mounted) setState(() => _theme = t);
    });

    // ZAMANLAYICI ile yapılandır+göster (frame beklemeden -> test bildirimi düzeldi)
    Future.delayed(const Duration(milliseconds: 400), _configureAndShow);

    _progressController = AnimationController(
      vsync: this,
      duration: _duration,
    );

    Future.delayed(_duration, _close);
  }

  Future<void> _configureAndShow() async {
    final title = (widget.data['title'] ?? '').toString();

    try {
      await widget.controller.setFrame(Rect.fromLTWH(_x, _y, _w, _h));
    } catch (_) {}

    try {
      await widget.controller.setTitle(title);
    } catch (_) {}

    _applyNativeWindowStyle(title);

    if (!_shown) {
      _shown = true;
      try {
        await widget.controller.show();
      } catch (_) {}
      _progressController.forward();
    }

    for (int i = 0; i < 4; i++) {
      await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
      if (_applyNativeWindowStyle(title)) {
        await Future.delayed(const Duration(milliseconds: 150));
        _applyNativeWindowStyle(title);
        break;
      }
    }
  }

  Future<void> _close() async {
    try {
      await widget.controller.close();
    } catch (_) {}
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final english = (widget.data['english'] ?? '').toString();
    final turkish = (widget.data['turkish'] ?? '').toString();
    final index = widget.data['index'];

    return Scaffold(
      backgroundColor: Color(_theme.colors.first),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: _theme.gradient),
        child: Stack(
          children: [
            // ===== ORTADA BÜYÜK KELİME =====
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _capitalize(english),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 1.5,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      color: Colors.white.withOpacity(0.25),
                    ),
                    Expanded(
                      child: Text(
                        _capitalize(turkish),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ===== SOL ÜST: INDEX =====
            if (index != null)
              Positioned(
                left: 12,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '#$index',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            // ===== SAĞ ÜST: KAPAT =====
            Positioned(
              right: 10,
              top: 8,
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 14,
                  ),
                ),
              ),
            ),
            // ===== ALT: SÜRE ÇUBUĞU =====
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) => LinearProgressIndicator(
                  value: 1 - _progressController.value,
                  minHeight: 3,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}