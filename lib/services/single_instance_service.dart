import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class SingleInstanceService {
  // Sabit port (ilk instance bu portu dinler)
  static const int _port = 47823;
  static ServerSocket? _server;

  /// true dönerse BU İLK instance'dır.
  /// false dönerse başka bir instance çalışıyordur -> bu kapanmalı.
  static Future<bool> ensure() async {
    try {
      // Port boşsa ilk instance biziz -> dinlemeye başla
      _server = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        _port,
      );

      _server!.listen((socket) {
        socket.listen((_) async {
          // İkinci exe çalıştırıldı -> pencereyi göster ve odaklan
          debugPrint('İkinci instance algılandı, pencere gösteriliyor...');
          try {
            await windowManager.show();
            await windowManager.focus();
          } catch (_) {}
        });
      });

      return true;
    } on SocketException {
      // Port dolu -> ilk instance zaten çalışıyor, ona sinyal gönder
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
      return true; // Hata durumunda normal devam et
    }
  }
}