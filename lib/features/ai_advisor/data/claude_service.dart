import 'dart:convert';

import 'package:http/http.dart' as http;

/// Anthropic Claude API'sine ham HTTP ile bağlanan servis.
///
/// API anahtarı derleme sırasında `--dart-define=CLAUDE_API_KEY=...` ile verilir.
/// Güvenlik notu: API anahtarını istemciye gömmek üretim için önerilmez
/// (gerçek uygulamada çağrı bir sunucu üzerinden yapılmalı); bu öğrenme
/// projesinde kabul edilebilir. Web'de CORS nedeniyle çalışmaz — yalnızca mobil.
class ClaudeService {
  static const String _apiKey = String.fromEnvironment('CLAUDE_API_KEY');
  static const String _model = 'claude-opus-4-8';
  static const String _endpoint = 'https://api.anthropic.com/v1/messages';

  /// Anahtar tanımlı mı? Değilse kural tabanlı özet kullanılır.
  bool get hasKey => _apiKey.isNotEmpty;

  /// Verilen istemi Claude'a gönderir ve metin yanıtını döndürür.
  Future<String> analyze(String prompt) async {
    if (!hasKey) {
      throw StateError('CLAUDE_API_KEY tanımlı değil.');
    }
    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'content-type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'system':
            'Sen kişisel finans danışmanısın. Türkçe, kısa ve uygulanabilir '
                'öneriler ver. Madde işaretleri kullan, en fazla 5 madde.',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Claude API hatası (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>?;
    if (content == null || content.isEmpty) return 'Yanıt alınamadı.';
    final first = content.first as Map<String, dynamic>;
    return (first['text'] as String?)?.trim() ?? 'Yanıt alınamadı.';
  }
}
