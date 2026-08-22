<div align="center">

# 📚 Kelime Hatırlatıcı / Word Reminder

<img src="https://img.shields.io/github/v/release/ERKANONER23/word_reminder_v2?style=for-the-badge&color=6C3483" alt="Release">
<img src="https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Platform">
<img src="https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
<img src="https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">

**🇹🇷 Windows için akıllı kelime hatırlatma uygulaması**
**🇬🇧 Smart word reminder for Windows**

<a href="https://github.com/ERKANONER23/word_reminder_v2/releases/latest/download/word_reminder_v2_windows_x64.zip">
  <img src="https://img.shields.io/badge/⬇_İNDİR_%2F_DOWNLOAD-Latest-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Download">
</a>

</div>

---

## 📑 İçindekiler / Table of Contents

- [🇹🇷 Türkçe Dokümantasyon](#-türkçe-dokümantasyon)
- [🇬🇧 English Documentation](#-english-documentation)

---

# 🇹🇷 TÜRKÇE DOKÜMANTASYON

## 1. 🎯 Genel Bakış

**Kelime Hatırlatıcı**, Windows üzerinde arka planda çalışan ve belirlediğiniz aralıklarla rastgele İngilizce kelimeleri **özel bir bildirim penceresinde** gösteren bir masaüstü uygulamasıdır. Flutter ile geliştirilmiştir.

### Neden Bu Uygulama?
- 🧠 **Pasif öğrenme**: Çalışırken, oyun oynarken kelimeler karşınıza çıkar
- 🎯 **Odak çalmaz**: Yazı yazarken bildirim gelse bile işiniz kesilmez
- 👻 **Hayalet mod**: Fare üzerine gelince saydamlaşır, tıklamalar arkaya geçer
- 💾 **Yerel depolama**: Hiçbir veri internete gönderilmez, gizliliğiniz korunur

---

## 2. ✨ Özellikler

### 📝 Kelime Yönetimi
- ➕ Kelime ekleme (mükerrer kontrolü + onay dialogu)
- 🗑️ Kelime silme (index veya kelime ile arama, onaylı)
- ✏️ Kelime düzenleme (index/kelime ile arama, dolu form)
- 🔍 **Kelime arama** (AppBar ikonu + **Ctrl+F** kısayolu)
- 🗂️ CSV içe/dışa aktarma (Excel uyumlu, akıllı başlık algılama)
- 📋 Son 3 bildirim + son 5 eklenen kelime kartları (tıklayınca düzenleme)

### 🔔 Bildirim Sistemi
- 🪟 Harici bildirim penceresi (sağ altta, çerçevesiz, her zaman üstte)
- 👻 **Tamamen pasif**: Odak çalmaz, yazarken imleç kıpırdamaz
- 🎯 **İmleç koruması**: Odak kaçsa bile imleç kaldığın yerde kalır, yazı seçili olmaz
- 💨 **Hover saydamlık**: Fare üzerine gelince ~%18 saydam, tıklamalar arkaya geçer
- 🎬 **Kademeli akış**: Panel → 1 sn → İngilizce → seçili gecikme → Türkçe
- 🎨 6 tema (Mor, Gece, Okyanus, Gün Batımı, Orman, Deltafin)
- 📏 3 boyut (Küçük / Orta / Büyük)
- ✍️ 5 yazı efekti (Yok / Solma / Pop / **Daktilo** / Kayma)
- ⏱️ Ayarlanabilir aralık (10 sn - 1 sa+) ve ekranda kalma süresi (2-60 sn)
- 🇹🇷 Türkçe anlam gecikmesi (0-10 sn)

### 💾 Yedekleme
- ✅ Varsayılan olarak AÇIK
- 📁 Varsayılan klasör: `exe_dizini/backup/`
- 🔄 Her açılışta + her değişiklikte otomatik yedek
- 📄 Tarih+saat damgalı CSV dosyaları
- 🗂️ Yedek klasörü **Seç** + **Aç** butonları

### 🖥️ Sistem Entegrasyonu
- 🚀 Windows ile otomatik başlatma
- 📌 Sistem tepsisi: göster / gizle / çıkış (çıkış adımları ekranı)
- 🔒 Tek instance koruması (exe'ye çift tıklamada mevcut uygulama öne gelir)
- 🌙 Koyu / Açık mod (kalıcı)
- 🪟 9:16 dikey pencere oranı (telefon görünümü)

### ⚙️ Ayarlar Ekranı
- 🎨 Her bölüm farklı renk tonunda kart
- 🔢 Başlıklarda anlık değerler (örn. `Bildirim Aralığı (300 sn)`)
- ⌨️ Tüm giriş alanlarında **Enter** desteği
- 🔐 Güvenlik kodlu **Ayarları Sıfırla** (sayıyı yazmadan sıfırlanmaz)

---

## 3. ⌨️ Kısayollar

| Kısayol | İşlev |
|---------|-------|
| `Enter` | Kelime ekle / onay |
| `ESC` | İptal / dialog kapat |
| `Ctrl+F` | Kelime arama (tüm ekranlarda) |
| `Ctrl+N` | Yeni kelime ekle (önerilen) |

---

## 4. 📦 Kurulum

### Son Kullanıcı (Kolay)
1. **Releases** sayfasından `word_reminder_v2_windows_x64.zip` indirin
2. Çıkartın
3. `kelime_hatiratici.exe` çalıştırın

✅ **Kurulum gerektirmez.** `sqlite3.dll` pakete dahildir.

### Geliştirici (Kaynaktan Derleme)

#### Gereksinimler
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (Windows desktop desteği)
- Visual Studio 2022 ("Desktop development with C++" workload)
- `sqlite3.dll` ([İndir](https://www.sqlite.org/download.html) → Precompiled Binaries for Windows)

#### Adımlar
```bash
# 1. Repoyu klonlayın
git clone https://github.com/ERKANONER23/word_reminder_v2.git
cd word_reminder_v2

# 2. sqlite3.dll'yi windows/ klasörüne kopyalayın
# (https://www.sqlite.org/download.html → sqlite-dll-win-x64-*.zip)

# 3. Paketleri yükleyin
flutter pub get

# 4. Çalıştırın
flutter run -d windows

# 5. Release derlemek için
flutter build windows --release
copy /Y windows\sqlite3.dll build\windows\x64\runner\Release\
```

---

## 5. 📖 Kullanım Kılavuzu

### İlk Başlangıç
1. Uygulamayı açın → sistem tepsisine yerleşir
2. Alt butonlardan **Kelime Ekle** ile ilk kelimenizi ekleyin
3. Bildirim süresi varsayılan **300 sn (5 dakika)** — sağ üstteki süre rozetine tıklayarak değiştirin

### Bildirim Akışı
```
t=0sn   ┌──────────────┐  Panel açılır (boş)
t=1sn   │ Apple        │  İngilizce görünür (efektli)
t=1+G   │ Apple │ Elma │  Türkçe görünür (efektli)
t=toplam│              │  Kapanır
        └──────────────┘
```

### Kelime Arama
1. AppBar'daki 🔍 ikonuna tıklayın **veya** `Ctrl+F` basın
2. İngilizce veya Türkçe yazın → sonuçlar anlık filtrelenir
3. Bir sonuca tıklayın → düzenleme formu açılır
4. `ESC` ile dialogu kapatın

### Hover Davranışı
- **Normal**: Kelime + ayraç + #index + süre çubuğu + X butonu
- **Hover**: Pencere saydamlaşır, tıklamalar arkaya geçer, sadece X belirgin kalır
- **Fare çekil**: Her şey normale döner

---

## 6. 🔧 Sorun Giderme

| Sorun | Çözüm |
|-------|-------|
| `exe` çalışmıyor | `sqlite3.dll` Release klasöründe mi? |
| Uygulama açılmıyor | Görev Yöneticisi'nde eski süreci sonlandırın |
| Bildirim gelmiyor | Sistem tepsisinden uygulamayı gösterin |
| `git push` reddedildi | `git pull --rebase origin master` sonra push |
| Windows SmartScreen uyarısı | "Yine de çalıştır" (imzasız uygulamalarda normal) |
| RAM artışı | Görev Yöneticisi'nde birikmiş process'leri sonlandırın |

---

## 7. 📁 Proje Yapısı

```
word_reminder_v2/
├── lib/
│   ├── main.dart                  # İki modlu giriş (ana + popup)
│   ├── app_globals.dart           # navigatorKey + odak yönetimi
│   ├── models/
│   │   └── word_model.dart        # Word veri modeli
│   ├── providers/
│   │   ├── theme_provider.dart
│   │   ├── word_provider.dart     # Otomatik yedek tetikleyici
│   │   ├── global_interval_provider.dart
│   │   └── notification_history_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart       # Ana ekran
│   │   ├── settings_screen.dart   # Renkli ayarlar
│   │   ├── shutdown_screen.dart   # Çıkış ekranı
│   │   └── notification_popup.dart # Harici bildirim
│   └── services/
│       ├── database_service.dart
│       ├── notification_service.dart
│       ├── notification_theme_service.dart
│       ├── notification_size_service.dart
│       ├── notification_animation_service.dart
│       ├── notification_behavior_service.dart
│       ├── background_service.dart
│       ├── tray_service.dart
│       ├── single_instance_service.dart
│       ├── auto_start_service.dart
│       ├── backup_service.dart
│       └── file_helper.dart
├── windows/
│   └── sqlite3.dll                # Veritabanı kütüphanesi
├── README.md
└── DOCUMENTATION.md               # Bu dosya
```

---

## 8. 🔐 Gizlilik

- ✅ **%100 yerel**: Tüm veriler bilgisayarınızda SQLite veritabanında saklanır
- ✅ **İnternet yok**: Hiçbir veri dışarı gönderilmez
- ✅ **Telemetri yok**: Kullanım izleme yok
- ✅ **Açık kaynak**: Kodun tamamı incelenebilir

---

# 🇬🇧 ENGLISH DOCUMENTATION

## 1. 🎯 Overview

**Word Reminder** is a desktop application that runs in the background on Windows and displays random English words in a **custom notification window** at your specified intervals. Built with Flutter.

### Why This App?
- 🧠 **Passive learning**: Words appear while you work or play
- 🎯 **Never steals focus**: Your work continues uninterrupted
- 👻 **Ghost mode**: Becomes transparent on hover, clicks pass through
- 💾 **Local storage**: No data sent online, your privacy is protected

---

## 2. ✨ Features

### 📝 Word Management
- ➕ Add words (duplicate check + confirmation)
- 🗑️ Delete words (search by index or word, confirmed)
- ✏️ Edit words (search by index/word, pre-filled form)
- 🔍 **Word search** (AppBar icon + **Ctrl+F** shortcut)
- 🗂️ CSV import/export (Excel compatible, smart header detection)
- 📋 Last 3 notifications + last 5 added words cards (click to edit)

### 🔔 Notification System
- 🪟 External notification window (bottom-right, frameless, always on top)
- 👻 **Completely passive**: Never steals focus, cursor doesn't move while typing
- 🎯 **Cursor protection**: Cursor stays where it was, text never gets selected
- 💨 **Hover transparency**: ~18% transparent on hover, clicks pass through
- 🎬 **Staged flow**: Panel → 1s → English → chosen delay → Turkish
- 🎨 6 themes (Purple, Night, Ocean, Sunset, Forest, Deltafin)
- 📏 3 sizes (Small / Medium / Large)
- ✍️ 5 text effects (None / Fade / Pop / **Typewriter** / Slide)
- ⏱️ Adjustable interval (10s - 1h+) and on-screen duration (2-60s)
- 🇹🇷 Turkish meaning delay (0-10s)

### 💾 Backup
- ✅ Enabled by default
- 📁 Default folder: `exe_directory/backup/`
- 🔄 Auto-backup on startup + every change
- 📄 Timestamped CSV files
- 🗂️ Backup folder **Choose** + **Open** buttons

### 🖥️ System Integration
- 🚀 Auto-start with Windows
- 📌 System tray: show / hide / exit (exit steps screen)
- 🔒 Single-instance protection (double-click brings existing app to front)
- 🌙 Dark / Light mode (persistent)
- 🪟 9:16 vertical window ratio (phone-like appearance)

### ⚙️ Settings Screen
- 🎨 Each section in a different color-toned card
- 🔢 Live values in titles (e.g., `Notification Interval (300s)`)
- ⌨️ **Enter** support in all input fields
- 🔐 Security-coded **Reset Settings** (requires typing a number)

---

## 3. ⌨️ Shortcuts

| Shortcut | Function |
|----------|----------|
| `Enter` | Add word / confirm |
| `ESC` | Cancel / close dialog |
| `Ctrl+F` | Search words (works everywhere) |
| `Ctrl+N` | Add new word (suggested) |

---

## 4. 📦 Installation

### End User (Easy)
1. Download `word_reminder_v2_windows_x64.zip` from **Releases**
2. Extract it
3. Run `kelime_hatiratici.exe`

✅ **No installation needed.** `sqlite3.dll` is included.

### Developer (Build from Source)

#### Requirements
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (with Windows desktop support)
- Visual Studio 2022 ("Desktop development with C++" workload)
- `sqlite3.dll` ([Download](https://www.sqlite.org/download.html) → Precompiled Binaries for Windows)

#### Steps
```bash
# 1. Clone the repository
git clone https://github.com/ERKANONER23/word_reminder_v2.git
cd word_reminder_v2

# 2. Copy sqlite3.dll to the windows/ folder
# (https://www.sqlite.org/download.html → sqlite-dll-win-x64-*.zip)

# 3. Install packages
flutter pub get

# 4. Run
flutter run -d windows

# 5. Build release
flutter build windows --release
copy /Y windows\sqlite3.dll build\windows\x64\runner\Release\
```

---

## 5. 📖 Usage Guide

### First Launch
1. Open the app → it settles in the system tray
2. Add your first word using **Add Word** button at the bottom
3. Default notification interval is **300s (5 min)** — click the time badge on top-right to change

### Notification Flow
```
t=0s    ┌──────────────┐  Panel opens (empty)
t=1s    │ Apple        │  English appears (with effect)
t=1+D   │ Apple │ Elma │  Turkish appears (with effect)
t=total │              │  Closes
        └──────────────┘
```

### Word Search
1. Click the 🔍 icon in AppBar **or** press `Ctrl+F`
2. Type in English or Turkish → results filter instantly
3. Click a result → edit form opens
4. Press `ESC` to close the dialog

### Hover Behavior
- **Normal**: Word + separator + #index + progress bar + X button
- **Hover**: Window becomes transparent, clicks pass through, only X stays visible
- **Mouse leaves**: Everything returns to normal

---

## 6. 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| `exe` won't run | Is `sqlite3.dll` in the Release folder? |
| App won't open | Kill the old process in Task Manager |
| No notifications | Show the app from system tray |
| `git push` rejected | `git pull --rebase origin master` then push |
| Windows SmartScreen warning | Click "Run anyway" (normal for unsigned apps) |
| RAM increase | Kill accumulated processes in Task Manager |

---

## 7. 📁 Project Structure

```
word_reminder_v2/
├── lib/
│   ├── main.dart                  # Two-mode entry (main + popup)
│   ├── app_globals.dart           # navigatorKey + focus management
│   ├── models/
│   │   └── word_model.dart        # Word data model
│   ├── providers/
│   │   ├── theme_provider.dart
│   │   ├── word_provider.dart     # Auto-backup trigger
│   │   ├── global_interval_provider.dart
│   │   └── notification_history_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart       # Main screen
│   │   ├── settings_screen.dart   # Colorful settings
│   │   ├── shutdown_screen.dart   # Exit screen
│   │   └── notification_popup.dart # External notification
│   └── services/
│       ├── database_service.dart
│       ├── notification_service.dart
│       ├── notification_theme_service.dart
│       ├── notification_size_service.dart
│       ├── notification_animation_service.dart
│       ├── notification_behavior_service.dart
│       ├── background_service.dart
│       ├── tray_service.dart
│       ├── single_instance_service.dart
│       ├── auto_start_service.dart
│       ├── backup_service.dart
│       └── file_helper.dart
├── windows/
│   └── sqlite3.dll                # Database library
├── README.md
└── DOCUMENTATION.md               # This file
```

---

## 8. 🔐 Privacy

- ✅ **100% local**: All data stored in local SQLite database
- ✅ **No internet**: No data is sent anywhere
- ✅ **No telemetry**: No usage tracking
- ✅ **Open source**: All code is auditable

---

## 🤝 Katkıda Bulunma / Contributing

Katkılar memnuniyetle karşılanır!
Contributions are welcome!

1. Fork edin / Fork the repo
2. Feature branch oluşturun / Create a feature branch (`git checkout -b feature/amazing`)
3. Commit edin / Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push edin / Push to branch (`git push origin feature/amazing`)
5. Pull Request açın / Open a Pull Request

---

## 📜 Lisans / License

**MIT License** — Detaylar için [LICENSE](LICENSE) dosyasına bakın.
See [LICENSE](LICENSE) file for details.

---

<div align="center">

**🇹🇷 Keyifli öğrenmeler! / 🇬🇧 Happy learning!** 🚀

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
⭐ If you like this project, don't forget to star it!

</div>
