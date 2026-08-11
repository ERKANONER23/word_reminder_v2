import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Tek instance + odak iade sinyali
class SingleInstanceService {
  static const int _port = 47823;
  static ServerSocket? _server;

  static Future<bool> ensure() async {
    try {
      _server = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        _port,
      );

      _server!.listen((socket) {
        socket.listen((data) async {
          final msg = String.fromCharCodes(data);

          if (msg == 'focus') {
            // SADECE odaklan (pencere zaten açık)
            await windowManager.focus();
          } else {
            // 'show' veya ikinci instance → göster + odakla
            debugPrint('İkinci instance algılandı, pencere gösteriliyor...');
            await windowManager.show();
            await windowManager.focus();
          }
        });
      });

      return true;
    } on SocketException {
      try {
        final socket = await Socket.connect(
          InternetAddress.loopbackIPv4,
          _port,
          timeout: const Duration(seconds: 2),
        );
        socket.write('show');
        await socket.flush();
        await socket.close();
      } catch (_) {}
      return false;
    } catch (e) {
      debugPrint('SingleInstance hatası: $e');
      return true;
    }
  }
}