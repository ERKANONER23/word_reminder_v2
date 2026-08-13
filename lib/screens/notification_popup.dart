import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import '../services/notification_theme_service.dart';
import '../services/notification_size_service.dart';

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
      SWP_FRAMECHANGED |
      SWP_NOMOVE |
      SWP_NOSIZE |
      SWP_NOACTIVATE,
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
  NotificationSize _size = notificationSizes[1];
  bool _shown = false;

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

    NotificationThemeService.getTheme().then((t) {
      if (mounted) setState(() => _theme = t);
    });
    NotificationSizeService.getSize().then((s) {
      if (mounted) setState(() => _size = s);
    });

    _earlyStyle();

    Future.delayed(const Duration(milliseconds: 400), _configureAndShow);

    _progressController = AnimationController(
      vsync: this,
      duration: _duration,
    );

    Future.delayed(_duration, _close);
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
      _showAndRestoreFocus(_title, _prevHwnd);
      _progressController.forward();
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

  /// FONT HESAPLAYICI (GERÇEK genişlikle):
  /// 1) En uzun KELİME maxWidth'e sığana kadar küçült → bölünme yok
  /// 2) Metin 3 satırı / yüksekliği aşarsa küçült
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

      // --- en uzun tek kelime genişliği ---
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

      // --- tüm metin: max 3 satır + yükseklik ---
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

  /// AKILLI YAZI:
  /// LayoutBuilder → GERÇEK sütun genişliğini okur (tahmin yok!)
  /// Böylece "Also" gibi kelimeler ASLA bölünmez.
  Widget _fitText(String text, double fontSize,
      {FontWeight fontWeight = FontWeight.normal, required Color color}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // GERÇEK kullanılabilir alan (Expanded'ın verdiği)
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        final fitted = _computeFontSize(
          text,
          fontSize,
          maxWidth,
          maxHeight,
          fontWeight: fontWeight,
        );

        return FittedBox(
          fit: BoxFit.scaleDown, // son güvenlik ağı
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              text,
              maxLines: 3,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: fitted,
                fontWeight: fontWeight,
              ),
            ),
          ),
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
            // ===== ORTADA KELİME =====
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
                    ),
                  ),
                ],
              ),
            ),
            // ===== SOL ÜST: #index =====
            if (index != null)
              Positioned(
                left: 12,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
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
            // ===== SAĞ ÜST: kapat =====
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
            // ===== ALT: süre çubuğu =====
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