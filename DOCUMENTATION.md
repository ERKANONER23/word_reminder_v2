# 📚 Kelime Hatırlatıcı / Word Reminder

**Sürüm / Version:** v2.8.0 · **Platform:** Windows 10/11 (64-bit) · **Framework:** Flutter
**Repo:** https://github.com/ERKANONER23/word_reminder_v2

---

# 🇹🇷 TÜRKÇE

## 1. Genel Bakış
Kelime Hatırlatıcı, Windows üzerinde arka planda çalışan ve belirlediğiniz
aralıklarla rastgele İngilizce kelimeleri **özel bir bildirim penceresinde**
gösteren bir masaüstü uygulamasıdır. Tüm veriler yalnızca yerel bilgisayarda
saklanır; internete hiçbir veri gönderilmez.

## 2. Özellikler
- ➕ Kelime ekle / 🗑 sil / ✏ düzenle (index veya kelime ile)
- 🔍 Kelime arama (AppBar ikonu + **Ctrl+F**)
- 🗂️ CSV içe/dışa aktarma (Excel uyumlu)
- 🔔 Harici bildirim penceresi: sağ altta, çerçevesiz, her zaman üstte
- ⌨️ Odak çalmaz; üzerine gelince **saydamlaşır ve tıklamayı arkaya geçirir**
- 🧠 Akıllı yazı: kelime bölünmez, en fazla 3 satır, font otomatik küçülür
- 🎨 6 tema · 📏 3 boyut · 🎬 5 yazı efekti (Yok/Solma/Pop/Daktilo/Kayma)
- 🇹🇷 Türkçe gecikme: önce İngilizce, seçili süre sonra Türkçe
- ⏱️ Ayarlanabilir bildirim aralığı + ekranda kalma süresi
- 💾 Otomatik yedekleme (`exe/backup`, tarih+saat damgalı CSV)
- 📌 Sistem tepsisi: göster / gizle / çıkış
- 🚀 Windows ile otomatik başlatma · 🔒 Tek instance koruması

## 3. Kurulum
1. Releases'ten `word_reminder_v2_windows_x64.zip` indirin
2. Çıkartın
3. `kelime_hatiratici.exe` çalıştırın
✅ Kurulum gerektirmez, `sqlite3.dll` dahildir.

**Kaynaktan derleme:**
```bash
git clone https://github.com/ERKANONER23/word_reminder_v2.git
cd word_reminder_v2
flutter pub get
flutter run -d windows
```
⚠️ `sqlite3.dll` dosyasını `windows/` klasörüne kopyalayın.

## 4. Kısayollar
| Tuş | İşlev |
|-----|-------|
| `Enter` | Kelime ekle / onay |
| `ESC` | İptal / dialog kapat |
| `Ctrl+F` | Kelime arama |

## 5. Sorun Giderme
| Sorun | Çözüm |
|-------|-------|
| exe çalışmıyor | `sqlite3.dll` Release klasöründe mi? |
| Uygulama açılmıyor | Görev Yöneticisi'nde eski süreci sonlandır |
| `git push` reddedildi | `git pull --rebase origin master` sonra push |

---

# 🇬 ENGLISH

## 1. Overview
Word Reminder is a Windows desktop app that runs in the background and shows
random English words with their Turkish meanings in a **custom notification
window** at your chosen intervals. All data is stored locally; nothing is sent
over the internet.

## 2. Features
- ➕ Add / 🗑 delete / ✏ edit words (by index or word)
- 🔍 Word search (AppBar icon + **Ctrl+F**)
- 🗂️ CSV import/export (Excel compatible)
- 🔔 External notification window: bottom-right, frameless, always on top
- ⌨️ Never steals focus; on hover it **turns transparent & clicks pass through**
- 🧠 Smart text: words never split, max 3 lines, auto font scaling
- 🎨 6 themes · 📏 3 sizes · 🎬 5 text effects (None/Fade/Pop/Typewriter/Slide)
- 🇹🇷 Turkish delay: English first, Turkish after chosen seconds
- ⏱️ Adjustable notification interval + on-screen duration
- 💾 Auto backup (`exe/backup`, timestamped CSV)
- 📌 System tray: show / hide / exit
- 🚀 Auto-start with Windows · 🔒 Single-instance protection

## 3. Installation
1. Download `word_reminder_v2_windows_x64.zip` from Releases
2. Extract it
3. Run `kelime_hatiratici.exe`
✅ No installation needed, `sqlite3.dll` included.

**Build from source:**
```bash
git clone https://github.com/ERKANONER23/word_reminder_v2.git
cd word_reminder_v2
flutter pub get
flutter run -d windows
```
⚠️ Copy `sqlite3.dll` into the `windows/` folder.

## 4. Shortcuts
| Key | Action |
|-----|--------|
| `Enter` | Add word / confirm |
| `ESC` | Cancel / close dialog |
| `Ctrl+F` | Search words |

## 5. Troubleshooting
| Issue | Fix |
|-------|-----|
| exe won't run | Is `sqlite3.dll` in the Release folder? |
| App won't open | Kill the old process in Task Manager |
| `git push` rejected | `git pull --rebase origin master` then push |

---

**Keyifli öğrenmeler! / Happy learning!** 🚀
