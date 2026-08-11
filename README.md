# 📚 Kelime Hatırlatıcı

Windows için geliştirilmiş, arka planda çalışan **kelime hatırlatma uygulaması**.
Flutter ile yazılmıştır. Belirlediğiniz aralıklarla rastgele kelimeleri
bildirim olarak göstererek kelime öğrenmenize yardımcı olur.

## ✨ Uygulamanın nasıl yapıldığına dair blog yazısı
https://dessaskod.wordpress.com/2026/08/09/flutter-qwen-ile-windows-icin-kelime-hatirlatici-sifirdan-yayina-adim-adim-bol-aciklamali-rehber/

## ✨ Özellikler

- 🪟 9:16 dikey pencere oranı (telefon görünümü)
- 🔔 Ayarlanabilir aralıklarla rastgele kelime bildirimi (saniye bazında)
-  Koyu / Açık mod
- 📋 Son 3 bildirim + son 5 eklenen kelime kartları
- ➕ Kelime ekle / sil / düzenle (index veya kelime ile)
- ⌨️ Kısayollar: `Enter` = ekle/onay, `ESC` = iptal
- 🗂️ CSV içe / dışa aktarma
- 🖥️ Windows ile otomatik başlatma
- 📌 Sistem tepsisi: göster / gizle / çıkış
- 💡 Tüm butonlarda tooltip açıklamaları
- 🎨 Modern kart tasarımı (iki sütunlu kelime görünümü)

## ⬇️ İndir (Windows)

<a href="https://github.com/ERKANONER23/word_reminder_v2/releases/latest/download/word_reminder_v2_windows_x64.zip">
  <img src="https://img.shields.io/badge/⬇_İNDİR-Son_Sürüm_(Windows)-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Son Sürümü İndir">
</a>

> 💡 Bu buton her zaman **en son yayınlanan sürümü** indirir — linki güncellemenize gerek kalmaz.
> 📦 **Kurulum gerektirmez!** ZIP'i indirip çıkartın, `kelime_hatiratici.exe`
> dosyasını çalıştırın. `sqlite3.dll` paketin içindedir.


## 🖼️ Ekran Görüntüleri

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/user-attachments/assets/8cfa9269-a7e1-42ec-958c-f0dd460ea9dc">
        <img src="https://github.com/user-attachments/assets/8cfa9269-a7e1-42ec-958c-f0dd460ea9dc" width="200" alt="Ekran 1">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/user-attachments/assets/bd7eb27a-162b-4aa8-b7f4-ac310c615925">
        <img src="https://github.com/user-attachments/assets/bd7eb27a-162b-4aa8-b7f4-ac310c615925" width="200" alt="Ekran 2">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/user-attachments/assets/547ece00-959d-40ab-9739-42fe454d89c5">
        <img src="https://github.com/user-attachments/assets/547ece00-959d-40ab-9739-42fe454d89c5" width="200" alt="Ekran 3">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/user-attachments/assets/4e09a8d7-f81b-4a67-8588-4f06d5340780">
        <img src="https://github.com/user-attachments/assets/4e09a8d7-f81b-4a67-8588-4f06d5340780" width="200" alt="Ekran 4">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/user-attachments/assets/e56049c9-8478-4757-a1df-467af7220c0e">
        <img src="https://github.com/user-attachments/assets/e56049c9-8478-4757-a1df-467af7220c0e" width="200" alt="Ekran 5">
      </a>
    </td>
  </tr>
</table>

## 📢 Örnek Bildirim

<img width="434" height="243" alt="Ekran görüntüsü 2026-08-08 231942" src="https://github.com/user-attachments/assets/6d01f658-7c00-4aac-ab61-7e3120da5466" />


## 🛠️ Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (Windows desktop desteğiyle)
- Visual Studio 2022 ("Desktop development with C++" workload)
- `sqlite3.dll` (aşağıya bakın)

⚠️ sqlite3.dll (ÖNEMLİ!)
Uygulamanın çalışması için sqlite3.dll gereklidir:
🔗 https://www.sqlite.org/download.html →
Precompiled Binaries for Windows → sqlite-dll-win-x64-*.zip
İçindeki sqlite3.dll dosyasını windows/ klasörüne kopyalayın
Release alırken dll otomatik kopyalanır (aşağıya bakın)

## 🚀 Kurulum ve Çalıştırma

```bash
# 1. Repoyu klonlayın
git clone https://github.com/ERKANONER23/kelime-hatirlatici.git
cd kelime-hatirlatici

# 2. Paketleri yükleyin
flutter pub get

# 3. Çalıştırın
flutter run -d windows
