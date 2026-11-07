# 🔒 Güvenlik Politikası

Bu belge, **Finansım** uygulamasının verileri ve gizli bilgileri nasıl
koruduğunu ve katkıda bulunanların uyması gereken kuralları açıklar.

## Cihazdaki veriler

- İşlemler, bütçeler, hedefler ve tekrarlayan ödemeler Hive kutularında
  **AES-256** ile şifrelenir. Anahtar `flutter_secure_storage` ile iOS
  Keychain / Android Keystore'da tutulur, veri dosyasının yanında değil.
- Kutular oturum açan hesabın kimliğinden türetilen adla açılır; aynı cihazda
  başka bir hesapla giriş yapıldığında önceki hesabın verisi görünmez.
- Android'de uygulama verisi bulut yedeğine ve cihazdan cihaza aktarıma dahil
  edilmez (`allowBackup=false`, `data_extraction_rules.xml`); şifresiz HTTP
  trafiği kapalıdır.
- İsteğe bağlı **uygulama kilidi** (Face ID / Touch ID / parmak izi) açılışta
  ve 30 saniyeden uzun arka planda kaldıktan sonra devreye girer; uygulama
  değiştiricide bakiyeler marka ekranıyla örtülür.
- Kullanıcı hesabını uygulama içinden silebilir; hesabın yerel verisi de silinir.
- Web sürümünde güvenli anahtar deposu olmadığından yerel şifreleme yalnızca
  mobil ve masaüstünde uygulanır.

## Sırların yönetimi

| Öğe | Nerede tutulur | Repo'da mı? |
|-----|----------------|-------------|
| **Claude API anahtarı** | Cloud Functions Secret Manager (`ANTHROPIC_API_KEY`) | ❌ Uygulamaya da repo'ya da girmez |
| **Release imzalama anahtarı** (`*.jks`, `key.properties`) | Yerel makine / CI secret | ❌ `.gitignore` ile hariç |
| **Servis hesabı JSON'ları** | Yerel / CI secret | ❌ `.gitignore` ile hariç |
| **Firebase istemci yapılandırması** (`firebase_options.dart`, `google-services.json`) | Repo içinde | ✅ Bilinçli olarak |

### Firebase istemci anahtarları neden repo'da?

Firebase'in istemci API anahtarları **geleneksel anlamda gizli değildir**;
yalnızca projeyi *tanımlar* ve mobil paketten zaten çıkarılabilir. Veriyi
koruyan şey sunucu tarafı kurallar ve App Check'tir.

Kaynak: [Firebase API anahtarları hakkında](https://firebase.google.com/docs/projects/api-keys)

## Yapay zeka danışmanı (`functions/`)

`aiAdvice` callable fonksiyonu Claude'a giden tek yoldur:

- Oturum açmış kullanıcı ve geçerli **App Check** belirteci ister.
- Yalnızca beş tam sayı skoru (0-100) kabul eder; istemi sunucu kurar.
  Böylece uç nokta genel amaçlı bir sohbet servisi olarak kötüye kullanılamaz
  ve işlem ayrıntıları cihazdan çıkmaz.
- Kullanıcı başına günlük 10 istek sınırı Firestore'daki `aiUsage`
  koleksiyonunda tutulur; `firestore.rules` bu koleksiyonu istemciye tamamen
  kapatır.

## Firebase Console'da yapılması gerekenler

1. **App Check** — Play Integrity (Android) ve App Attest / DeviceCheck (iOS)
   sağlayıcılarını etkinleştir ve Cloud Functions için zorunlu kıl.
2. **API anahtarı kısıtlama** — Google Cloud Console → Credentials → API key →
   uygulama paketi + SHA-256 imza parmak iziyle sınırla.
3. **Apple ile giriş** — Authentication → Sign-in method → Apple'ı etkinleştir.
4. **Yetkili alan adları** — Auth → Settings → yalnızca kendi alan adların.

## Bir güvenlik açığı bildirme

Bir güvenlik sorunu bulursan lütfen **herkese açık issue açma**; bunun yerine
depo sahibiyle özel olarak iletişime geç.
