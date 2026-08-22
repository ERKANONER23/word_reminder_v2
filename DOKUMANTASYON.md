# 📚 Kelime Hatırlatıcı (Word Reminder) — Dökümantasyon

**Sürüm:** v2.6.0 · **Platform:** Windows 10/11 (64-bit) · **Framework:** Flutter (Dart)
**Repo:** https://github.com/ERKANONER23/word_reminder_v2

---

## 📖 İçindekiler

1. [Genel Bakış](#1-genel-bakış)
2. [Özellikler](#2-özellikler)
3. [Sistem Gereksinimleri](#3-sistem-gereksinimleri)
4. [Kurulum](#4-kurulum)
5. [Kullanıcı Rehberi](#5-kullanıcı-rehberi)
6. [Yedekleme Sistemi](#6-yedekleme-sistemi)
7. [Teknik Dökümantasyon](#7-teknik-dökümantasyon)
8. [Release ve Dağıtım](#8-release-ve-dağıtım)
9. [Sorun Giderme (SSS)](#9-sorun-giderme-sss)
10. [Sürüm Geçmişi](#10-sürüm-geçmişi)

---

## 1. Genel Bakış

**Kelime Hatırlatıcı**, Windows üzerinde arka planda çalışan ve belirlediğiniz
aralıklarla rastgele İngilizce kelimeleri **özel bir bildirim penceresinde**
ekranın sağ alt köşesinde gösteren bir masaüstü uygulamasıdır. Amaç, gün
boyunca kelimelerle pasif tekrar yaparak kelime öğrenmeyi kolaylaştırmaktır.

Uygulama Flutter ile yazılmıştır; pencere yönetimi, sistem tepsisi, harici
bildirim penceresi ve native Windows API işlemleri için plugin ekosisteminden
yararlanır. Tüm veriler **yalnızca yerel bilgisayarda** saklanır (SQLite + CSV
yedek); hiçbir veri internete gönderilmez.

---

## 2. Özellikler

### 📝 Kelime Yönetimi
- ➕ Kelime ekleme / 🗑 silme / ✏️ düzenleme (index veya kelime ile)
- ⌨️ Kısayollar: `Enter` = ekle/onay, `ESC` = iptal
- 🔁 Mükerrer kelime kontrolü (onay dialogu ile)
- 🗂️ CSV içe / dışa aktarma (Excel uyumlu)

### 🔔 Bildirim Sistemi
- 🪟 **Özel harici bildirim penceresi** (Windows toast'u yerine)
- 📍 Sağ alt köşede, görev çubuğunun hemen üstünde tam hizalı
- 🚫 Çerçevesiz; görev çubuğunda ve Alt-Tab'da görünmez
- 📌 Her zaman üstte
- ⌨️ **Odak çalmaz** — yazı yazarken bildirim gelse bile klavye odağı kaybolmaz
- 🧠 Akıllı yazı motoru: kelime asla bölünmez, en fazla 3 satır, sığmazsa font
  otomatik küçülür, asla kırpılmaz
- 🎨 6 tema (Mor, Gece, Okyanus, Gün Batımı, Orman, Deltafin)
- 📏 3 boyut (Küçük / Orta / Büyük)
- ⏱️ 6 saniye sonra otomatik kapanır, X ile manuel kapatılabilir

### 🖥️ Pencere ve Sistem
- 📱 9:16 dikey pencere oranı (boyutlandırınca korunur)
- 🌙 Koyu / Açık mod (tercih kalıcı olarak kaydedilir)
- 📋 Son 3 bildirim + son 5 eklenen kelime kartları (iki sütunlu, ortalanmış,
  tıklayınca düzenleme açılır)
- 📌 Sistem tepsisi: göster / gizle / çıkış
- 🎬 Kapatırken adım adım işlemleri gösteren kapanış penceresi
- 🚀 Windows ile otomatik başlatma
- 🔒 Tek instance koruması (ikinci exe mevcut uygulamayı öne getirir)
- 💡 Tüm butonlarda tooltip açıklamaları

### 💾 Yedekleme
- ✅ Otomatik yedek varsayılan olarak AÇIK
- 📁 Varsayılan klasör: exe'nin yanındaki `backup\` (otomatik oluşur)
- 🕐 Açılışta ve her kelime değişikliğinde yedek alır
- 📄 Tarih+saat damgalı tek yedek dosyası
- ☁️ OneDrive/Dropbox klasörü seçilerek buluta yedekleme imkânı

---

## 3. Sistem Gereksinimleri

| Bileşen | Gereksinim |
|---------|-----------|
| İşletim Sistemi | Windows 10 / 11 (64-bit) |
| Disk | ~50 MB |
| Kurulum | **Gerekmez** (portable) |
| Ekstra | Yok (`sqlite3.dll` pakete dahildir) |

### Geliştirici için (kaynaktan derleme)
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
  (Windows desktop desteğiyle)
- Visual Studio 2022 — "Desktop development with C++" workload
- `sqlite3.dll` → [sqlite.org/download.html](https://www.sqlite.org/download.html)
  → *Precompiled Binaries for Windows*

---

## 4. Kurulum

### 4.1 Son kullanıcı (ZIP)
1. **Releases** bölümünden `word_reminder_v2_windows_x64.zip` indirin
2. ZIP'i istediğiniz bir klasöre çıkartın
3. `kelime_hatiratici.exe` dosyasını çalıştırın ✅

> ⚠️ **Önemli:** ZIP'teki **tüm dosyaları birlikte** tutun — sadece `.exe`
> tek başına çalışmaz!
> 🛡️ Windows SmartScreen "bilinmeyen yayıncı" uyarısı verebilir →
> **"Yine de çalıştır"** deyin (imzasız uygulamalarda normaldir).

### 4.2 Kaynaktan derleme
```bash
git clone https://github.com/ERKANONER23/word_reminder_v2.git
cd word_reminder_v2
flutter pub get
flutter run -d windows
```

### 4.3 Release alma
```bash
flutter clean
flutter pub get
flutter build windows --release
copy /Y windows\sqlite3.dll build\windows\x64\runner\Release\
```

> ⚠️ `sqlite3.dll` kopyalanmazsa release exe **çalışmaz**!

## 5. Kullanıcı Rehberi

### 5.1 Ana Ekran Görünümü

```
┌──────────────────────────────────────────────┐
│ [👁][⏻]      Kelime Hatiratici    [🌙][300 sn][⚙] │
├──────────────────────────────────────────────┤
│              🔔 Son Bildirimler               │
│  [3]   Apple      │      Elma        [Yeni]  │
│  [2]   Book       │      Kitap               │
│           📋 Son Eklenen Kelimeler            │
│  [5]   Also       │      Ayrıca da   [Yeni]  │
│                                              │
│  [Kelime Sil] [Kelime Düzenle] [Kelime Ekle]  │
└──────────────────────────────────────────────┘
```

| Bölüm | İşlevi |
|-------|--------|
| 👁 Gizle | Uygulamayı sistem tepsisine gizler + "arka planda çalışıyor" bildirimi gösterir |
| ⏻ Kapat | Onay penceresi → kapanış adımları → güvenli kapanış |
| 🌙 Switch | Koyu/Açık mod (tercih kalıcı olarak kaydedilir) |
| ⏱ Süre rozeti | Tıklayınca bildirim aralığını saniye cinsinden ayarlarsınız |
| ⚙ Ayarlar | Tüm ayarlar penceresi |
| Kart satırları | Herhangi bir kelime satırına tıklarsanız **düzenleme penceresi** açılır |

### 5.2 Kelime Ekleme
1. **Kelime Ekle** butonuna basın (veya ana ekranda `Enter`'a basın)
2. İngilizce kelimeyi ve Türkçe anlamını yazın
3. **Kaydet** veya `Enter`
4. Aynı kelime zaten varsa "Yine de eklensin mi?" onayı çıkar

### 5.3 Kelime Silme
1. **Kelime Sil** butonuna basın
2. Index numarası (`1`) veya kelimenin kendisini (`Apple`) yazın
3. `Enter` veya **Sil** → onay penceresi → kalıcı silme

### 5.4 Kelime Düzenleme
- **Kelime Düzenle** butonu → index/kelime girin → form **dolu** açılır → düzeltin → Kaydet
- veya ana ekrandaki kart satırına **tıklayın** → direkt düzenleme açılır

### 5.5 Klavye Kısayolları
| Tuş | Nerede | İşlev |
|-----|--------|-------|
| `Enter` | Ana ekran | Kelime ekleme penceresini açar |
| `Enter` | Dialog içinde | Onaylar / kaydeder |
| `ESC` | Dialog içinde | İptal eder, pencereyi kapatır |

### 5.6 Bildirim Sistemi
- Belirlediğiniz aralıkla **rastgele bir kelime** ekranın **sağ alt köşesinde** ayrı bir pencerede belirir
- Pencere **çerçevesizdir**, **her zaman üstte** kalır, görev çubuğunda ve Alt-Tab'da **görünmez**
- **Odak çalmaz:** siz yazı yazarken bildirim gelse bile klavye odağı sizde kalır
- **6 saniye** sonra kendiliğinden kapanır; sağ üstteki **X** ile manuel kapatılabilir
- **Akıllı yazı motoru:** kelime asla ortadan bölünmez, en fazla **3 satır** kullanılır, sığmazsa yazı boyutu otomatik küçülür — kırpma imkânsızdır

**Bildirim Temaları (6):** Mor, Gece, Okyanus, Gün Batımı, Orman, Deltafin
> Deltafin teması koyu lacivert arkaplan + açık mavi yazı + mavi vurgu rengi kullanır.

**Bildirim Boyutları (3):** Küçük (380×130), Orta (430×150), Büyük (520×190)
> Boyut seçimi Ayarlar → Bildirim Boyutu bölümünden yapılır ve kalıcıdır.

### 5.7 Bildirim Sıklığını Ayarlama
İki yol vardır:
1. **Süre rozetine tıklayın** (AppBar'daki `300 sn` yazan rozet) → saniye girin
2. **Ayarlar → Bildirim Sıklığı:** hazır çipler (`5 dk`, `15 dk`, `30 dk`, `1 sa`) veya **Özel Süre** alanına saniye yazıp **Uygula**

### 5.8 Gizleme ve Kapatma Davranışı
| Eylem | Sonuç |
|-------|-------|
| **X butonu** | Kapatmaz, tepsiye gizler + bilgi bildirimi |
| **👁 Gizle** | Tepsiye gizler + bilgi bildirimi |
| **⏻ Kapat** | Onay → adımlar tek tek ✅ olur → güvenli kapanış |
| **Tepsi → Çıkış** | Pencere açılır → aynı kapanış adımları → kapanış |
| **Tepsi → Göster / sol tık** | Pencereyi geri getirir |

### 5.9 Kapanış Ekranı
Kapat dediğinizde aynı pencere içinde işlemler sırayla gösterilir:
```
✅ Bildirim zamanlayıcısı durduruluyor
✅ Veriler kaydediliyor
✅ Sistem tepsisi temizleniyor
✅ Uygulama kapatılıyor
```
Bu, verilerinizin hiçbir zaman riske girmeden güvenle kaydedildiğinin garantisidir.

---

## 6. Yedekleme Sistemi

### 6.1 Nasıl Çalışır?
- **Otomatik yedek varsayılan olarak AÇIK'tır** — kurulumdan sonra elle hiçbir şey yapmanıza gerek yoktur
- Yedek, şu anlarda otomatik yazılır:
  - Uygulama **açılışında**
  - Her **kelime ekleme / düzenleme / silme** işleminde
  - **CSV içe aktarma** sonrasında

### 6.2 Yedek Klasörü
- **Varsayılan konum:** uygulamanın (`exe`) bulunduğu klasörün içindeki `backup\` klasörü
```
C:\Apps\KelimeHatiratici\
├── kelime_hatiratici.exe
├── sqlite3.dll
└── backup\                              ← otomatik oluşur
    ├── kelime_yedek_2026-08-13_14-30-45.csv   ← otomatik yedek (TEK, en güncel)
    └── kelimeler_1723549845123.csv             ← sizin manuel dışa aktarımlarınız
```
- Klasör yoksa uygulama **kendisi oluşturur**

### 6.3 Dosya Adları
| Tür | Format | Açıklama |
|-----|--------|----------|
| Otomatik yedek | `kelime_yedek_YYYY-AA-GG_SS-DD-SS.csv` | Tarih + saat damgalı; her yedeklemede eski otomatik yedek silinir, **tek güncel dosya** kalır |
| Manuel dışa aktarım | `kelimeler_<zaman>.csv` | Sizin dışa aktardığınız dosyalar **asla silinmez** |

### 6.4 Ayarlar → Otomatik Yedekleme Bölümü
| Öğe | İşlevi |
|-----|--------|
| **Otomatik Yedek** anahtarı | Yedeklemeyi aç/kapat |
| **Yedek Klasörü** satırı | Aktif yedek klasörünün yolunu gösterir |
| **Klasör Seç** butonu | Yedeklerin yazılacağı klasörü değiştirir |
| **Klasörü Aç** butonu | Aktif yedek klasörünü Dosya Gezgini'nde açar |

> 💡 **Bulut yedeği ipucu:** "Klasör Seç" ile **OneDrive** veya **Dropbox** klasörünüzü seçerseniz yedekleriniz aynı zamanda buluta da yüklenir.

### 6.5 Geri Yükleme (Yedeği Geri Getirme)
1. Ayarlar → **İçe Aktar** butonuna basın
2. `backup\` klasöründeki `kelime_yedek_....csv` dosyasını seçin
3. Kelimeler otomatik olarak geri yüklenir (mükerrer olanlar atlanır)

### 6.6 Dışa Aktar ile Yedek Arasındaki Fark
| Özellik | Otomatik Yedek | Dışa Aktar |
|---------|----------------|------------|
| Ne zaman | Kendiliğinden, her değişiklikte | Siz butona bastığınızda |
| Konum | Yedek klasörü (varsayılan exe/backup) | Siz seçersiniz (varsayılan yedek klasörü açılır) |
| Amaç | Veri güvenliği | Paylaşım / Excel'de düzenleme / başka PC'ye taşıma |

## 7. Teknik Dökümantasyon

### 7.1 Genel Mimari

Uygulama **tek `main()` içinde iki modda** çalışır:

```dart
void main(List<String> args) async {
  // MOD 2: Bildirim popup penceresi
  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.parse(args[1]);
    final controller = WindowController.fromWindowId(windowId);
    // ... sadece popup UI'ı çalışır
    return; // ana akış kesilir
  }
  // MOD 1: Ana uygulama
  // ...
}
```

`desktop_multi_window` paketi yeni pencere doğurduğunda `main()`'i
`["multi_window", windowId, jsonVerisi]` ile tekrar çağırır; bu dalda yalnızca
bildirim arayüzü çalışır.

**Katman yapısı:**

| Katman | İçerik | Sorumluluk |
|--------|--------|------------|
| `models/` | `Word` | Veri modeli (toMap/fromMap) |
| `providers/` | Riverpod StateNotifier'lar | Reaktif durum (kelime listesi, tema, süre, geçmiş) |
| `services/` | Servis sınıfları | DB, bildirim, tepsi, yedek, otomatik başlatma, tek instance |
| `screens/` | Arayüzler | Ana ekran, ayarlar, kapanış, bildirim popup |

**Desen:** Önce veritabanına yaz, sonra state'i tazele → UI asla DB ile
çelişmez. Tüm servisler **Singleton**'dır; hatalar `try-catch` ile yutulur ki
bir servisin hatası uygulamayı asla çökertmesin.

### 7.2 Proje Yapısı

```
lib/
├── main.dart                  ← iki modlu giriş + servis orkestrasyonu
├── app_globals.dart           ← navigatorKey (servis→UI köprüsü)
├── models/
│   └── word_model.dart
├── providers/
│   ├── word_provider.dart     ← her değişiklikte otomatik yedek tetikler
│   ├── theme_provider.dart    ← kalıcı koyu/açık mod
│   ├── global_interval_provider.dart
│   └── notification_history_provider.dart
├── screens/
│   ├── home_screen.dart       ← kartlar + alt butonlar + dialoglar
│   ├── settings_screen.dart   ← süre/tema/boyut/veri/yedek/sistem
│   ├── shutdown_screen.dart   ← ExitDialog (adımlı kapanış)
│   └── notification_popup.dart← harici bildirim penceresi + win32 stil
└── services/
    ├── database_service.dart  ← SQLite singleton (CRUD)
    ├── notification_service.dart
    ├── notification_theme_service.dart  ← 6 tema + renk sistemi
    ├── notification_size_service.dart   ← 3 boyut
    ├── background_service.dart← 10 sn'de bir "süre doldu mu?"
    ├── tray_service.dart      ← tepsi + debug/release ikon yolu
    ├── window_listener.dart   ← X=gizle + 9:16 oran kilidi
    ├── single_instance_service.dart ← port 47823 koruması
    ├── auto_start_service.dart
    ├── backup_service.dart    ← otomatik CSV yedek
    └── file_helper.dart       ← CSV içe/dışa aktarma
```

### 7.3 Veritabanı Şeması

```sql
CREATE TABLE words(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  english TEXT NOT NULL,
  turkish TEXT NOT NULL
);
```

### 7.4 Kalıcı Ayarlar (SharedPreferences)

| Anahtar | İçerik | Varsayılan |
|---------|--------|------------|
| `theme_mode` | `dark` / `light` / `system` | `system` |
| `global_interval_seconds` | Bildirim aralığı (sn) | `300` |
| `notification_history` | Son 3 bildirim (JSON) | boş |
| `notification_theme` | Seçili tema id | `mor` |
| `notification_size` | Seçili boyut id | `orta` |
| `backup_enabled` | Otomatik yedek | `true` (AÇIK) |
| `backup_folder` | Yedek klasörü | `exe/backup` |

### 7.5 Önemli Algoritmalar

**1) Akıllı Yazı Motoru (kelime bölünmez, kırpma imkânsız)**

```dart
// LayoutBuilder GERÇEK sütun genişliğini/yüksekliğini verir (tahmin yok)
// 1. En uzun TEK kelime sütuna sığana kadar font 2'şer px küçülür
//    → kelime asla "Pancak/e" diye BÖLÜNMEZ
// 2. Metin 3 satırı veya yüksekliği aşarsa font küçülmeye devam eder
// 3. Son güvenlik: FittedBox(scaleDown) → taşma/kırpma imkânsız
```

**2) Sağ Alt Köşe Hesabı (canlı sistem ölçüleri)**

```dart
double screenW = GetSystemMetrics(SM_CXSCREEN).toDouble();
double screenH = GetSystemMetrics(SM_CYSCREEN).toDouble();
// Shell_TrayWnd → görev çubuğunun ÜST kenarı = çalışma alanı sınırı
// x = screenW - w - 12 ; y = görevÇubuğuÜstü - h - 12
```

Ekran/ölçekleme değişse bile her gösterimde yeniden ölçüldüğü için
bildirim **tam köşeye** oturur.

**3) Odak Koruması (4 katman)**

1. Ana uygulama bildirimden ÖNCE `GetForegroundWindow()` ile aktif pencereyi kaydeder
2. Popup doğar doğmaz `WS_EX_NOACTIVATE` uygulanır (tıklansa bile odak almaz)
3. Gösterim `SW_SHOWNOACTIVATE` ile yapılır (odak çalmaz)
4. Sigorta: 100 ms sonra odak kaçtıysa `SetForegroundWindow(prevHwnd)` +
   soket üzerinden `'focus'` sinyali → klavye odağı yazdığın yerde kalır

**4) Native Pencere Stili (win32)**

| Bayrak | Etkisi |
|--------|--------|
| `~WS_CAPTION` | Başlık çubuğunu (—/□/X) kaldırır |
| `~WS_THICKFRAME` | Kenarlıktan boyutlandırmayı kapatır |
| `WS_EX_TOOLWINDOW` | Görev çubuğu ve Alt-Tab'dan gizler |
| `HWND_TOPMOST` + `SWP_NOACTIVATE` | Her zaman üstte, odak çalmadan |

**5) Tek Instance (çift açılma koruması)**

İlk instance `127.0.0.1:47823` portunu dinler; ikinci exe portu dolu bulur,
`'show'` mesajı gönderip kendini kapatır (`exit(0)`); ilk instance penceresini
gösterir/odaklar. Popup ayrıca `'focus'` mesajıyla odak iadesi ister.

**6) Yedekleme Stratejisi (tek dosya kuralı)**

- Her yedeklemede `kelime_yedek_*` önekli eski otomatik dosyalar silinir,
  güncel tarih+saat damgalı **tek** dosya yazılır:
  `kelime_yedek_2026-08-13_14-30-45.csv`
- Manuel dışa aktarımlar `kelimeler_*` öneki taşır → otomatik temizlikten
  **etkilenmez**, aynı klasörde güvenle birikir.

**7) Güvenli Kapanış (ExitDialog)**

`exit(0)` yerine doğal kapanış tercih edilmiştir: onay → aynı dialog içinde
adımlar tek tek ✅ olur (zamanlayıcı durduruluyor → veriler kaydediliyor →
tepsi temizleniyor → kapatılıyor) → `windowManager.destroy()`.
Yavaş ama **sorunsuz** kapanır; veri kaybı riski sıfırdır.

---

## 8. Release ve Dağıtım

### 8.1 Release Komutları

```bash
flutter clean
flutter pub get
flutter build windows --release
copy /Y windows\sqlite3.dll build\windows\x64\runner\Release\
```

> ⚠️ `sqlite3.dll` hiçbir pakete gömülü gelmez — kopyalanmazsa exe
> **açılmaz** (log "Binding hazır" satırında kalır).

İsteğe bağlı tek-tık script (`build_release.bat`):

```bat
@echo off
call flutter clean
call flutter pub get
call flutter build windows --release
copy /Y windows\sqlite3.dll build\windows\x64\runner\Release\
echo TAMAM! Release hazir.
pause
```

### 8.2 ZIP ve GitHub Release

1. `Release` klasörünün **içindeki her şeyi** ZIP'le →
   **`word_reminder_v2_windows_x64.zip`** (her sürümde aynı isim!)
2. Kodu push et:

```bash
git add .
git commit -m "v2.6.0: ..."
git pull --rebase origin master
git push
```

3. Repo → **Releases → Create a new release** → Tag: `v2.6.0` →
   ZIP'i **Attach binaries** alanına sürükle → **Publish release**

README'deki indirme butonu `releases/latest/download/...` linkine baktığı
için, ZIP adı sabit kaldıkça buton **otomatik olarak her zaman en son
sürümü** indirir.

### 8.3 Dağıtım Kuralları

| Kural | Neden |
|-------|-------|
| Tüm klasörü birlikte taşı | exe, dll'leri ve `data/`'yı yanında arar |
| ASCII yol kullan (`C:\Apps\...`) | Türkçe karakter/boşluk bazı sistemlerde sorun çıkarır |
| Eski süreci sonlandır | Uygulama tepsiye gizlendiği için arka planda kalabilir |
| SmartScreen uyarısı normaldir | İmzasız uygulamalarda "Yine de çalıştır" denir |

---

## 9. Sorun Giderme (SSS)

Geliştirme sürecinde **gerçekten yaşanmış** hatalar ve çözümleri:

| Sorun | Teşhis / Çözüm |
|-------|----------------|
| exe taşınınca hiç açılmıyor, log "Binding hazır"da kalıyor | `sqlite3.dll` eksik → Release klasörüne kopyala |
| "Application finished" / pencere açılmıyor | Arka planda eski süreç portu tutuyor → Görev Yöneticisi'nden sonlandır |
| `git push` reddedildi | README GitHub'da düzenlenmiş → `git pull --rebase` sonra push |
| Koyu mod kapanınca kayboluyor | Tercih RAM'deydi → SharedPreferences'a yaz |
| Kelime bölünüyor ("Pancak/e") | `AutoSizeText` harften bölüyordu → TextPainter ile kelime ölçümü |
| "Also" bile bölündü | Tahmini genişlik yanlıştı → `LayoutBuilder` ile gerçek ölçüm |
| `keybd_event` tanımsız | Yeni win32'ten kaldırıldı → soket tabanlı `'focus'` sinyali |
| `GetWindowLong` tanımsız | 64-bit sürümde `GetWindowLongPtr` kullan |
| `setAsTopmost` tanımsız | Paket sürümünde yok → kaldırıldı (SetWindowPos yeterli) |
| `Pointer<RECT>.right` hatası | Pointer içine `.ref` ile erişilir |
| `launchAtStartup.setup` void hatası | `setup()` void döndürür → `await` kullanma |
| Tepsi ikonu release'de kayboluyor | Debug/release ikon yolları farklı → çift yol kontrolü |
| Bildirim odağı çalıyor | 4 katmanlı odak koruması (NOACTIVATE + soket iadesi) |
| Beyaz boş bildirim penceresi | Pencere içerik hazır olmadan gösteriliyordu → popup kendini yapılandırıp gösterir + retry |

---

## 10. Sürüm Geçmişi

| Sürüm | Öne Çıkanlar |
|-------|--------------|
| v1.0.0 | İlk sürüm: kelime ekle/sil, bildirimler, sistem tepsisi, CSV, otomatik başlatma |
| v2.0.0 | Kapanış ekranı, tek instance, kart tasarımı, kelime düzenleme |
| v2.1.0 | Harici bildirim penceresi, bildirim temaları, düzenleme akışı |
| v2.2.0 | 3 bildirim boyutu, odak koruması, alt satıra kırma, tepsiden çıkış ekranı |
| v2.3.0 | Deltafin teması, tema seçici tek satır |
| v2.4.0 | Kelime bölünmez font ölçekleme, Deltafin renk sistemi (yazı/vurgu) |
| v2.5.0 | LayoutBuilder gerçek ölçümlü akıllı yazı, kırpma imkânsız (max 3 satır) |
| v2.6.0 | Otomatik yedekleme (exe/backup varsayılan), tarih+saat damgalı tek yedek, Klasör Seç/Aç butonları, kompakt süre çipleri |

---

**Keyifli öğrenmeler!** 🚀
