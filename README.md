# 💰 Finansım — AI Destekli Kişisel Finans Uygulaması

Flutter ile geliştirilmiş, **premium tasarımlı** ve **gerçek veriyle çalışan** kişisel finans yönetim uygulaması. Gelir/gider takibi, bütçe, birikim hedefleri, canlı döviz kurları, makbuz okuma (OCR) ve yapay zekâ destekli finansal analiz sunar.

> Temiz Mimari (Clean Architecture), Riverpod ve Firebase üzerine kurulu; 25+ ekran, offline-first veri katmanı ve CI/CD içerir.

---

## ✨ Öne Çıkan Özellikler

| Alan | Açıklama |
|------|----------|
| 🔐 **Kimlik Doğrulama** | Firebase Auth (e-posta/şifre), biyometrik giriş, OTP doğrulama ekranı |
| 📊 **Dashboard & İstatistikler** | Canlı bakiye, aylık trend grafikleri (fl_chart), kategori dağılımı |
| 💸 **İşlemler** | Gelir/gider ekleme-düzenleme, tarihe göre gruplama, gelişmiş arama & filtre |
| 🎯 **Birikim Hedefleri** | Hedef oluştur, birikim ekle, ilerleme takibi (Hive) |
| 📅 **Bütçe & Tekrarlayan Ödemeler** | Kategori bazlı aylık limitler, abonelik/fatura takibi |
| 💱 **Döviz Kurları & Çevirici** | **Canlı TCMB API**'sinden gerçek alış/satış kurları, para çevirici |
| 🧾 **Makbuz Okuyucu (OCR)** | **Google ML Kit** ile fişten tutar/tarih/satıcı tanıma → işleme dönüştürme |
| 🤖 **Yapay Zekâ Danışmanı** | Gerçek verilerden finansal sağlık skoru + **Claude API** ile doğal dil analizi |
| 🔔 **Akıllı Bildirimler** | Bütçe uyarıları, yaklaşan ödemeler ve hedef ilerlemesinden otomatik üretilir |
| 🎨 **Tema & Yerelleştirme** | Açık/Koyu/Sistem teması (kalıcı), çoklu para birimi desteği |

---

## 🏗️ Mimari

Feature-first **Clean Architecture** yapısı:

```
lib/
├── config/           # tema (design tokens), yönlendirme (go_router)
├── core/             # sabitler, yardımcılar (Formatters, Validators)
├── shared/           # yeniden kullanılabilir widget'lar (AppCard, AppBackButton...)
└── features/
    └── <özellik>/
        ├── data/           # servisler, model dönüşümleri
        ├── domain/         # saf iş varlıkları (entity) — framework bağımsız
        └── presentation/   # ekranlar, provider'lar, widget'lar
```

- **State yönetimi:** Riverpod 3.x (Notifier / StreamProvider / Provider)
- **Yerel veri:** Hive (offline-first — işlemler, bütçe, hedefler, tekrarlayan ödemeler, ayarlar)
- **Uzak servisler:** Firebase Auth, TCMB döviz API, Claude API (opsiyonel), Google ML Kit
- **Tasarım sistemi:** Merkezî design token'ları (renk, boşluk, radius, tipografi) — hardcode değer yok

---

## 🛠️ Teknoloji Yığını

`Flutter 3.x` · `Dart 3.x` · `Riverpod` · `Firebase Auth` · `Hive` · `go_router` · `fl_chart` · `google_mlkit_text_recognition` · `image_picker` · `http` · `intl` · `google_fonts`

---

## 🚀 Kurulum

```bash
# Bağımlılıkları yükle
flutter pub get

# Android/iOS emülatör veya cihazda çalıştır
flutter run

# Web'de çalıştır (hızlı önizleme)
flutter run -d chrome
```

### Yapay Zekâ analizini etkinleştirme (opsiyonel)

AI danışmanı, anahtar tanımlı değilse **kural tabanlı** öneriler üretir. Gerçek Claude analizi için:

```bash
flutter run --dart-define=CLAUDE_API_KEY=sk-ant-...
```

> Güvenlik notu: API anahtarını istemciye gömmek üretim için önerilmez; gerçek dağıtımda çağrı bir arka uç üzerinden yapılmalıdır. Web'de CORS nedeniyle yalnızca mobilde çalışır.

---

## 🧪 Testler

```bash
flutter analyze   # statik analiz (0 uyarı)
flutter test      # birim testleri
```

Saf iş mantığı için birim testleri: `Formatters`, `SavingsGoal`, `TransactionFilter`, işlem modeli, doğrulayıcılar. Her push'ta **GitHub Actions** analiz + test + web build çalıştırır.

---

## 📁 Proje Durumu

- ✅ Çekirdek akış (auth, işlemler, dashboard, istatistik, bütçe, hedefler, tekrarlayan) **gerçek veriyle** çalışıyor
- ✅ Döviz kurları/çevirici **canlı TCMB API**
- ✅ OCR **gerçek ML Kit**, AI **gerçek/kural tabanlı** analiz
- ✅ Açık/Koyu tema, çoklu para birimi, bildirimler gerçek olaylardan
- 🔜 Bulut senkronizasyonu (Firestore), iOS native yayın (TestFlight), çoklu dil

---

## 📝 Lisans

Bu proje eğitim ve portföy amaçlıdır.
