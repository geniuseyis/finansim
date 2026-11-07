# 💰 Finansım — AI Destekli Kişisel Finans Uygulaması

[![CI](https://github.com/geniuseyis/finansim/actions/workflows/ci.yml/badge.svg)](https://github.com/geniuseyis/finansim/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-informational)

Flutter ile geliştirilmiş, **premium tasarımlı** ve **gerçek veriyle çalışan** kişisel finans yönetim uygulaması. Gelir/gider takibi, bütçe, birikim hedefleri, canlı döviz kurları, makbuz okuma (OCR) ve yapay zekâ destekli finansal analiz sunar.

> Temiz Mimari (Clean Architecture), Riverpod ve Firebase üzerine kurulu; 25+ ekran, offline-first veri katmanı ve CI/CD içerir.

---

## ✨ Öne Çıkan Özellikler

| Alan | Açıklama |
|------|----------|
| 🔐 **Kimlik Doğrulama** | Firebase Auth: e-posta/şifre, Google ve Apple ile giriş, Anahtar Zinciri otomatik doldurma, uygulama içinden hesap silme |
| 🛡️ **Güvenlik** | Face ID / Touch ID / parmak izi ile uygulama kilidi, uygulama değiştiricide gizlilik örtüsü, cihazda AES-256 şifreli ve hesaba özel veri |
| 📊 **Dashboard & İstatistikler** | Canlı bakiye, gün/hafta/ay/yıl dönem filtresi ve önceki dönemle karşılaştırma, kategori dağılımı (fl_chart) |
| 💸 **İşlemler** | Gelir/gider ekleme-düzenleme, tarihe göre gruplama, gelişmiş arama & filtre |
| 🎯 **Birikim Hedefleri** | Hedef oluştur, birikim ekle, ilerleme takibi (Hive) |
| 📅 **Bütçe & Tekrarlayan Ödemeler** | Kategori bazlı aylık limitler, abonelik/fatura takibi |
| 💱 **Döviz Kurları & Çevirici** | **Canlı TCMB API**'sinden gerçek alış/satış kurları, para çevirici |
| 🧾 **Makbuz Okuyucu (OCR)** | **Google ML Kit** ile fişten tutar/tarih/satıcı tanıma → işleme dönüştürme |
| 🤖 **Yapay Zekâ Danışmanı** | Gerçek verilerden finansal sağlık skoru + **Claude** ile doğal dil analizi (Cloud Functions üzerinden; anahtar uygulamada değil) |
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
- **Yerel veri:** Hive (offline-first — işlemler, bütçe, hedefler, tekrarlayan ödemeler, ayarlar); finans kutuları AES-256 şifreli, anahtar Keychain / Android Keystore'da
- **Uzak servisler:** Firebase Auth, App Check, Cloud Functions (`functions/`, Claude proxy'si), TCMB döviz API, Google ML Kit
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

AI danışmanı, bulut fonksiyonu kurulu değilse cihazda **kural tabanlı** öneriler üretir. Claude analizi `functions/` altındaki `aiAdvice` fonksiyonundan gelir; API anahtarı yalnızca Secret Manager'da durur. Fonksiyon oturum + App Check ister, yalnızca 0-100 arası skorları kabul eder ve kullanıcı başına günde 10 analizle sınırlıdır.

```bash
# Firebase projesi Blaze planında olmalı; Firestore etkin olmalı (kota sayacı için)
cd functions && npm ci && cd ..
firebase functions:secrets:set ANTHROPIC_API_KEY
firebase deploy --only functions,firestore:rules
```

---

## 🧪 Testler

```bash
flutter analyze   # statik analiz (0 uyarı)
flutter test      # birim testleri
```

Saf iş mantığı için birim testleri: `Formatters`, `SavingsGoal`, `TransactionFilter`, dönem bazlı `FinanceSummary`, işlem modeli. Her push'ta **GitHub Actions** analiz + test + web build ve bulut fonksiyonu bağımlılık denetimi çalıştırır.

---

## 📁 Proje Durumu

- ✅ Çekirdek akış (auth, işlemler, dashboard, istatistik, bütçe, hedefler, tekrarlayan) **gerçek veriyle** çalışıyor
- ✅ Döviz kurları/çevirici **canlı TCMB API**
- ✅ OCR **gerçek ML Kit**, AI **gerçek/kural tabanlı** analiz
- ✅ Açık/Koyu tema, çoklu para birimi, bildirimler gerçek olaylardan
- ✅ Ekranlarda örnek/uydurma veri yok; işlevi olmayan buton bırakılmadı
- 🔜 Bulut senkronizasyonu (Firestore), iOS native yayın (TestFlight), çoklu dil

---

## 🔒 Güvenlik

- Claude API anahtarı uygulamaya hiç girmez; Cloud Functions Secret Manager'da durur.
- Finans verisi cihazda AES-256 ile şifreli ve hesaba özeldir; Android yedeğine dahil edilmez.
- Gizli anahtarlar (imzalama keystore, servis hesapları) **repo'ya girmez**; `.gitignore` ile korunur.
- Firebase istemci yapılandırması repo'dadır — bu anahtarlar [Google'a göre gizli değildir](https://firebase.google.com/docs/projects/api-keys); koruma **Firebase Security Rules + App Check** ile sağlanır.
- Ayrıntılar ve önerilen sertleştirmeler: **[SECURITY.md](SECURITY.md)**

## 📝 Lisans

Bu proje eğitim ve portföy amaçlıdır.
