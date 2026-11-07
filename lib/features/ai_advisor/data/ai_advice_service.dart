import 'package:cloud_functions/cloud_functions.dart';

/// Yapay zeka danışmanı önerilerini `aiAdvice` bulut fonksiyonundan alır.
///
/// Claude API anahtarı uygulamada değil, sunucuda (Secret Manager) durur.
/// Fonksiyon oturum ve App Check doğrulaması ister, kullanıcı başına günlük
/// sınır uygular. Cihazdan yalnızca 0-100 arası skorlar gider; işlem
/// listesi, tutarlar ya da açıklamalar hiçbir zaman gönderilmez.
class AiAdviceService {
  AiAdviceService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _functions;

  Future<String> analyze(Map<String, int> scores) async {
    try {
      final result = await _functions
          .httpsCallable(
            'aiAdvice',
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 90),
              // Sunucu belirteci tek kullanımlık tüketir (replay koruması).
              limitedUseAppCheckToken: true,
            ),
          )
          .call<Map<String, dynamic>>(scores);
      final text = (result.data['text'] as String?)?.trim();
      if (text == null || text.isEmpty) {
        throw const AiAdviceException('Yanıt alınamadı.');
      }
      return text;
    } on FirebaseFunctionsException catch (e) {
      throw AiAdviceException(switch (e.code) {
        'resource-exhausted' =>
          e.message ?? 'Günlük analiz hakkın doldu, yarın tekrar dene.',
        'unauthenticated' => 'Analiz için yeniden giriş yapman gerekiyor.',
        'not-found' || 'unavailable' || 'internal' =>
          'AI servisine şu an ulaşılamıyor.',
        _ => e.message ?? 'Analiz yapılamadı.',
      });
    }
  }
}

class AiAdviceException implements Exception {
  const AiAdviceException(this.message);
  final String message;

  @override
  String toString() => message;
}
