import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import '../services/notification_theme_service.dart';
import '../services/notification_size_service.dart';
import '../services/notification_animation_service.dart';
import '../services/notification_behavior_service.dart';

/// Çerçevesiz + ÜSTTE + GÖREV ÇUBUĞUNDA YOK + ODAK ÇALMAZ
bool _applyNativeWindowStyle(String title) {
  try {
    final titlePtr = title.toNativeUtf16();
    final hwnd = FindWindow(nullptr, titlePtr);
    free(titlePtr);
    if (hwnd == 0) return false;
    final style = GetWindowLongPtr(hwnd, GWL_STYLE);
    SetWindowLongPtr(
      hwnd,
      GWL_STYLE,
      style & ~WS_CAPTION & ~WS_THICKFRAME,
    );
    final exStyle = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
    SetWindowLongPtr(
      hwnd,
      GWL_EXSTYLE,
      exStyle | WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE,
    );
    SetWindowPos(
      hwnd,
      HWND_TOPMOST,
      0,
      0,
      0,
      0,
      SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE,
    );
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> _sendToMain(String msg) async {
  try {
    final socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      47823,
      timeout: const Duration(seconds: 1),
    );
    socket.write(msg);
    await socket.flush();
    await socket.close();
  } catch (_) {}
}

void _showAndRestoreFocus(String title, int prevHwnd) {
  try {
    final titlePtr = title.toNativeUtf16();
    final hwnd = FindWindow(nullptr, titlePtr);
    free(titlePtr);
    if (hwnd == 0) return;
    ShowWindow(hwnd, SW_SHOWNOACTIVATE);
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        final fg = GetForegroundWindow();
        if (fg == hwnd) {
          if (prevHwnd != 0) SetForegroundWindow(prevHwnd);
          await _sendToMain('focus');
        }
      } catch (_) {}
    });
  } catch (_) {}
}

/// SADECE ANA MONİTÖR: sağ alt köşeyi canlı sistem ölçüleriyle hesaplar
Rect _computeBottomRight(double w, double h) {
  double screenW = GetSystemMetrics(SM_CXSCREEN).toDouble();
  double screenH = GetSystemMetrics(SM_CYSCREEN).toDouble();
  double bottom = screenH;
  try {
    final cls = 'Shell_TrayWnd'.toNativeUtf16();
    final taskbar = FindWindow(cls, nullptr);
    free(cls);
    if (taskbar != 0) {
      final r = calloc<RECT>();
      if (GetWindowRect(taskbar, r) != 0) {
        final tbW = (r.ref.right - r.ref.left).toDouble();
        if (tbW >= screenW - 4) {
          bottom = r.ref.top.toDouble();
        }
      }
      free(r);
    }
  } catch (_) {}
  final x = screenW - w - 12;
  final y = bottom - h - 12;
  return Rect.fromLTWH(x, y, w, h);
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
  const PopupScreen({super.key, required this.controller, required this.data});

  @override
  State<PopupScreen> createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;

  NotificationTheme _theme = notificationThemes.first;
  NotificationSize _size = notificationSizes[1];
  String _animationId = 'default';
  int _displayDurationSec = 6;
  int _turkishDelaySec = 0;
  int _totalSeconds = 7;

  bool _shown = false;
  bool _showEnglish = false; // 1 sn sonra true
  bool _showTurkish = false; // 1 + gecikme sonra true

  Color get _text => Color(_theme.textColor);
  Color get _sub => Color(_theme.subColor);
  Color get _accent => Color(_theme.accentColor);
  String get _title => (widget.data['title'] ?? '').toString();
  int get _prevHwnd =>
      (widget.data['prevHwnd'] is int) ? widget.data['prevHwnd'] as int : 0;

  String _capitalize(String text) => text.isEmpty
      ? text
      : text[0].toUpperCase() + text.substring(1).toLowerCase();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    _loadPrefs();
    _earlyStyle();
    Future.delayed(const Duration(milliseconds: 400), _configureAndShow);
  }

  Future<void> _loadPrefs() async {
    final t = await NotificationThemeService.getTheme();
    final s = await NotificationSizeService.getSize();
    final a = await NotificationAnimationService.getAnimation();
    final dur = await NotificationBehaviorService.getDuration();
    final delay = await NotificationBehaviorService.getTurkishDelay();
    if (!mounted) return;
    setState(() {
      _theme = t;
      _size = s;
      _animationId = a;
      _displayDurationSec = dur;
      _turkishDelaySec = delay;
      // TOPLAM = 1sn (İngilizce gecikmesi) + Türkçe gecikmesi + izleme süresi
      _totalSeconds = 1 + delay + dur;
      _progressController.dispose();
      _progressController = AnimationController(
        vsync: this,
        duration: Duration(seconds: _totalSeconds),
      );
    });
  }

  Future<void> _earlyStyle() async {
    try {
      await widget.controller.setTitle(_title);
    } catch (_) {}
    _applyNativeWindowStyle(_title);
  }

  Future<void> _configureAndShow() async {
    try {
      await widget.controller
          .setFrame(_computeBottomRight(_size.w, _size.h));
    } catch (_) {}
    try {
      await widget.controller.setTitle(_title);
    } catch (_) {}
    _applyNativeWindowStyle(_title);
    if (!_shown) {
      _shown = true;
      try {
        await widget.controller.show();
      } catch (_) {}
      _showAndRestoreFocus(_title, _prevHwnd);
      _progressController.forward();

      // ===== KADEMELİ AKIŞ =====
      // 1 sn sonra İngilizce
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _showEnglish = true);
      });
      // 1 + gecikme sn sonra Türkçe
      Future.delayed(Duration(seconds: 1 + _turkishDelaySec), () {
        if (mounted) setState(() => _showTurkish = true);
      });
      // toplam süre sonunda kapat
      Future.delayed(Duration(seconds: _totalSeconds), _close);
    }
    for (int i = 0; i < 4; i++) {
      await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
      if (_applyNativeWindowStyle(_title)) {
        await Future.delayed(const Duration(milliseconds: 150));
        _applyNativeWindowStyle(_title);
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

  /// FONT HESAPLAYICI: kelime bölünmez, max 3 satır, sığmazsa küçülür
  double _computeFontSize(
      String text,
      double desired,
      double maxWidth,
      double maxHeight, {
        FontWeight fontWeight = FontWeight.normal,
      }) {
    double size = desired;
    while (size > 8) {
      final style = TextStyle(
        fontSize: size,
        fontWeight: fontWeight,
        color: Colors.white,
      );
      double maxWordWidth = 0;
      for (final word in text.split(RegExp(r'\s+'))) {
        if (word.isEmpty) continue;
        final wp = TextPainter(
          text: TextSpan(text: word, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        if (wp.width > maxWordWidth) maxWordWidth = wp.width;
      }
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 3,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);
      final wordFits = maxWordWidth <= maxWidth;
      final linesFit = !tp.didExceedMaxLines;
      final heightFits = tp.height <= maxHeight;
      if (wordFits && linesFit && heightFits) break;
      size -= 2;
    }
    return size;
  }

  /// Akıllı yazı + kademeli görünürlük + animasyon
  Widget _fitText(
      String text,
      double fontSize, {
        FontWeight fontWeight = FontWeight.normal,
        required Color color,
        required bool visible,
      }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitted = _computeFontSize(
          text,
          fontSize,
          constraints.maxWidth,
          constraints.maxHeight,
          fontWeight: fontWeight,
        );
        return _RevealText(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fitted,
            fontWeight: fontWeight,
          ),
          anim: _animationId,
          visible: visible,
        );
      },
    );
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
            // ===== ORTADA KELİME (kademeli) =====
            Positioned(
              left: 14,
              right: 14,
              top: 30,
              bottom: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _fitText(
                      _capitalize(english),
                      _size.fontEn,
                      fontWeight: FontWeight.bold,
                      color: _text,
                      visible: _showEnglish,
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: _sub.withOpacity(0.35),
                  ),
                  Expanded(
                    child: _fitText(
                      _capitalize(turkish),
                      _size.fontTr,
                      color: _sub,
                      visible: _showTurkish,
                    ),
                  ),
                ],
              ),
            ),
            if (index != null)
              Positioned(
                left: 12,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '#$index',
                    style: TextStyle(
                      color: _sub,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 10,
              top: 8,
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: _sub,
                    size: 14,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) => LinearProgressIndicator(
                  value: 1 - _progressController.value,
                  minHeight: 3,
                  backgroundColor: _accent.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==================== GECİKMELİ + ANİMASYONLU YAZI ====================
/// visible=true olunca animasyonu başlatır (Timer tabanlı daktilo = sağlam).
class _RevealText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final String anim;
  final bool visible;
  const _RevealText({
    required this.text,
    required this.style,
    required this.anim,
    required this.visible,
  });

  @override
  State<_RevealText> createState() => _RevealTextState();
}

class _RevealTextState extends State<_RevealText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  Timer? _typeTimer;
  int _typed = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.visible) _start();
  }

  @override
  void didUpdateWidget(_RevealText old) {
    super.didUpdateWidget(old);
    if (!old.visible && widget.visible) _start();
  }

  void _start() {
    if (_started) return;
    _started = true;
    if (widget.anim == 'typewriter') {
      // Timer tabanlı: her 55ms'de bir karakter (kesin çalışır)
      _typeTimer = Timer.periodic(const Duration(milliseconds: 55), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() => _typed++);
        if (_typed >= widget.text.length) t.cancel();
      });
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Widget _plain(String s, {bool caret = false}) => Text(
    caret ? '$s▌' : s,
    maxLines: 3,
    softWrap: true,
    textAlign: TextAlign.center,
    style: widget.style,
  );

  @override
  Widget build(BuildContext context) {
    // Henüz görünme zamanı gelmedi → yer tut (opak 0)
    if (!widget.visible) {
      return Opacity(opacity: 0, child: _plain(widget.text));
    }
    switch (widget.anim) {
      case 'typewriter':
        final n = _typed.clamp(0, widget.text.length);
        return _plain(
          widget.text.substring(0, n),
          caret: n < widget.text.length,
        );
      case 'fade':
        return FadeTransition(opacity: _ctrl, child: _plain(widget.text));
      case 'pop':
        return FadeTransition(
          opacity: _ctrl,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
            child: _plain(widget.text),
          ),
        );
      case 'slide':
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.6, 0), end: Offset.zero)
              .animate(
              CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: _ctrl, child: _plain(widget.text)),
        );
      default:
        return _plain(widget.text);
    }
  }
}