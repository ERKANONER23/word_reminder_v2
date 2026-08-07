# 📚 Kelime Hatırlatıcı

Windows için geliştirilmiş, arka planda çalışan **kelime hatırlatma uygulaması**.
Flutter ile yazılmıştır. Belirlediğiniz aralıklarla rastgele kelimeleri
bildirim olarak göstererek kelime öğrenmenize yardımcı olur.

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

## 🖼️ Ekran Görüntüleri

<!-- Ekran görüntüsü eklemek için:
1. Görüntüyü alın
2. Bu satırı silip yerine şunu yazın:
![Uygulama](ekran_goruntusu.png)
-->

## 🛠️ Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (Windows desktop desteğiyle)
- Visual Studio 2022 ("Desktop development with C++" workload)
- `sqlite3.dll` (aşağıya bakın)

## 🚀 Kurulum ve Çalıştırma

```bash
# 1. Repoyu klonlayın
git clone https://github.com/KULLANICI_ADINIZ/kelime-hatirlatici.git
cd kelime-hatirlatici

# 2. Paketleri yükleyin
flutter pub get

# 3. Çalıştırın
flutter run -d windows
