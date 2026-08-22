import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Aynı uygulamadan İKİ pencere açılmasını engeller.
///
/// MANTIK:
/// • İLK instance 47823 portunu DİNLER.
/// • İKİNCİ instance portu dolu bulur → "show" mesajı gönderir → kapanır.
/// • İlk instance mesajı alınca penceresini gösterir/odaklar.
class SingleInstanceService {
  static const int _port = 47823;
  static ServerSocket? _server;

  /// true = bu ilk instance; false = başkası çalışıyor, biz kapanmalıyız.
  static Future<bool> ensure() async {
    try {
      // Port boşsa ilk biziz → sunucuyu kur
      _server = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        _port,
      );
      _server!.listen((socket) {
        socket.listen((data) async {
          final msg = String.fromCharCodes(data);
          if (msg == 'focus') {
            // Sadece odaklan (bildirim odağı iadesi için)
            try {
              await windowManager.focus();
            } catch (_) {}
          } else {
            // 'show' → ikinci instance → göster + odakla
            debugPrint('İkinci instance algılandı, pencere gösteriliyor...');
            try {
              await windowManager.show();
              await windowManager.focus();
            } catch (_) {}
          }
        });
      });
      return true;
    } on SocketException {
      // Port DOLU → ilk instance çalışıyor; ona "göster" de ve kapan.
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

  /// KAPANIŞTA ÇAĞIRILIR: soketi kapatır, portu serbest bırakır.
  /// Böylece kapanan süreç portu TUTAMAZ; yeni başlatılan exe
  /// portu boş bulur ve NORMAL şekilde açılır. (Hayalet süreç fix'i)
  static void dispose() {
    try {
      _server?.close();
      _server = null;
    } catch (_) {}
  }
}