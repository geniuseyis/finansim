// Finansım bulut fonksiyonları.
//
// aiAdvice: Yapay zeka danışmanı için Claude'a giden tek kapı. API anahtarı
// yalnızca burada, Secret Manager'da durur; uygulamanın içine hiç girmez.
// İstemci ham işlem verisi değil, yalnızca 0-100 arası skorları gönderir ve
// istem (prompt) burada kurulur. Böylece uç nokta genel amaçlı bir sohbet
// servisi olarak kötüye kullanılamaz.

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const functionsV1 = require('firebase-functions/v1');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const Anthropic = require('@anthropic-ai/sdk');

initializeApp();

const ANTHROPIC_API_KEY = defineSecret('ANTHROPIC_API_KEY');
const MODEL = 'claude-opus-5-5';
const DAILY_LIMIT = 10;
const SCORE_KEYS = ['overall', 'income', 'savings', 'spending', 'budget'];

const SYSTEM = [
  'Sen Finansım uygulamasının kişisel finans danışmanısın.',
  'Kullanıcının finansal sağlık skorlarına bakarak Türkçe, kısa ve uygulanabilir',
  'öneriler ver. En fazla 5 madde yaz, her madde "• " ile başlasın.',
  'Yatırım ürünü, hisse ya da kripto tavsiyesi verme; bütçe, tasarruf ve',
  'harcama alışkanlıklarına odaklan. Motive edici ama gerçekçi ol.',
].join(' ');

function readScores(data) {
  if (!data || typeof data !== 'object') {
    throw new HttpsError('invalid-argument', 'Skorlar eksik.');
  }
  const scores = {};
  for (const key of SCORE_KEYS) {
    const value = data[key];
    if (!Number.isInteger(value) || value < 0 || value > 100) {
      throw new HttpsError('invalid-argument', `Geçersiz skor: ${key}`);
    }
    scores[key] = value;
  }
  return scores;
}

// Kullanıcı başına günlük istek sınırı (UTC gününe göre).
async function takeQuota(uid) {
  const day = new Date().toISOString().slice(0, 10);
  const ref = getFirestore().collection('aiUsage').doc(uid);
  await getFirestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const used = snap.exists && snap.get('day') === day ? snap.get('count') : 0;
    if (used >= DAILY_LIMIT) {
      throw new HttpsError('resource-exhausted', 'Günlük analiz hakkın doldu.');
    }
    tx.set(ref, { day, count: used + 1, updatedAt: FieldValue.serverTimestamp() });
  });
}

exports.aiAdvice = onCall(
  {
    region: 'europe-west1',
    secrets: [ANTHROPIC_API_KEY],
    enforceAppCheck: true,
    // Her App Check belirteci yalnızca bir kez kullanılabilir; ele geçirilen
    // bir belirteçle istek tekrarlanıp ücretli API harcatılamaz.
    consumeAppCheckToken: true,
    maxInstances: 5,
    timeoutSeconds: 120,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Oturum açman gerekiyor.');
    }
    const s = readScores(request.data);
    await takeQuota(request.auth.uid);

    const prompt = [
      'Finansal durumumu değerlendir ve öneriler ver.',
      `- Finansal sağlık skoru: ${s.overall}/100`,
      `- Gelir yönetimi: ${s.income}/100`,
      `- Tasarruf oranı: ${s.savings}/100`,
      `- Harcama kontrolü: ${s.spending}/100`,
      `- Bütçe uyumu: ${s.budget}/100`,
    ].join('\n');

    const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY.value() });
    try {
      const response = await client.beta.messages.create({
        model: MODEL,
        max_tokens: 16000,
        output_config: { effort: 'low' },
        betas: ['server-side-fallback-2026-07-01'],
        fallbacks: 'default',
        system: SYSTEM,
        messages: [{ role: 'user', content: prompt }],
      });

      if (response.stop_reason === 'refusal') {
        throw new HttpsError('failed-precondition', 'Şu an öneri üretilemedi.');
      }
      const text = response.content
        .filter((block) => block.type === 'text')
        .map((block) => block.text)
        .join('\n')
        .trim();
      if (!text) throw new HttpsError('internal', 'Boş yanıt alındı.');
      return { text };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      if (error instanceof Anthropic.RateLimitError) {
        throw new HttpsError('resource-exhausted', 'Servis yoğun, biraz sonra dene.');
      }
      if (error instanceof Anthropic.APIError) {
        logger.error('Claude API hatası', { status: error.status });
        throw new HttpsError('unavailable', 'AI servisine ulaşılamadı.');
      }
      logger.error('aiAdvice beklenmeyen hata', error);
      throw new HttpsError('internal', 'Beklenmeyen bir hata oluştu.');
    }
  },
);

// Hesap silinince o kullanıcıya ait sunucu kaydını (günlük kota sayacı) da sil.
// Uygulama hesabı cihazdaki verilerle birlikte siler; sunucuda iz kalmasın.
exports.deleteUserData = functionsV1
  .region('europe-west1')
  .auth.user()
  .onDelete(async (user) => {
    await getFirestore().collection('aiUsage').doc(user.uid).delete();
  });
