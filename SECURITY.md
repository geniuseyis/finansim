# 🔒 Güvenlik Politikası

Bu belge, **Finansım** uygulamasının gizli bilgileri nasıl ele aldığını ve
katkıda bulunanların uyması gereken kuralları açıklar.

## Sırların yönetimi

| Öğe | Nerede tutulur | Repo'da mı? |
|-----|----------------|-------------|
| **Claude API anahtarı** | Derleme zamanı `--dart-define=CLAUDE_API_KEY=...` | ❌ Asla commit edilmez |
| **Release imzalama anahtarı** (`*.jks`, `key.properties`) | Yerel makine / CI secret | ❌ `.gitignore` ile hariç |
| **Servis hesabı JSON'ları** | Yerel / CI secret | ❌ `.gitignore` ile hariç |
| **Firebase istemci yapılandırması** (`firebase_options.dart`, `google-services.json`) | Repo içinde | ✅ Bilinçli olarak |

### Firebase istemci anahtarları neden repo'da?

Firebase'in istemci API anahtarları **geleneksel anlamda gizli değildir**.
Google'ın resmî açıklamasına göre bu anahtarlar yalnızca projeyi *tanımlar*;
veriyi koruyan şey anahtar değil, **sunucu tarafı kurallardır**. Mobil bir
uygulamada bu anahtar zaten paketten çıkarılabilir. Bu yüzden repo'da
bulunmaları bir sızıntı değildir.

Kaynak: [Firebase API anahtarları hakkında](https://firebase.google.com/docs/projects/api-keys)

## Yapılması önerilen sunucu tarafı sertleştirmeler

Gerçek koruma Firebase Console'da yapılır (kod tarafında değil):

1. **Firebase Security Rules** — Firestore/Storage kurallarını yalnızca
   `request.auth != null` olan kullanıcıya kendi verisine erişecek şekilde kısıtla.
2. **Firebase App Check** — yalnızca senin uygulamandan gelen isteklerin
   backend'e ulaşmasını sağlar (Play Integrity / DeviceCheck).
3. **API anahtarı kısıtlama** — Google Cloud Console → Credentials → API key →
   uygulama paketi + SHA-256 imza parmak iziyle sınırla.
4. **Yetkili alan adları** — Auth → Settings → yalnızca kendi alan adların.

## Claude API kullanımı

AI danışman özelliği anahtar verilmezse **kural tabanlı** çalışır. Anahtar
verildiğinde istemciden doğrudan Anthropic API'sine gider — bu üretim için
**önerilmez**; gerçek dağıtımda çağrı bir **arka uç (proxy)** üzerinden yapılmalı
ve anahtar sunucuda tutulmalıdır. Bu proje eğitim/portföy amaçlıdır.

## Bir güvenlik açığı bildirme

Bir güvenlik sorunu bulursan lütfen **herkese açık issue açma**; bunun yerine
depo sahibiyle özel olarak iletişime geç.
