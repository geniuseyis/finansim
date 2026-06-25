/// Yalnızca `data` katmanında fırlatılan teknik istisnalar (exceptions).
///
/// Kural: Exception'lar `data` katmanında fırlatılır ve orada yakalanıp
/// bir [Failure]'a dönüştürülür. `domain` ve `presentation` katmanları
/// asla ham Exception görmez; onlar yalnızca [Failure] ile çalışır.
library;

/// Uzak veri kaynağı (Firestore, API) bir hata döndürdüğünde fırlatılır.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Sunucu hatası.']);
}

/// Yerel önbellek okuma/yazma sırasında bir sorun olduğunda fırlatılır.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Önbellek hatası.']);
}

/// Kimlik doğrulama işlemi başarısız olduğunda fırlatılır.
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Kimlik doğrulama hatası.']);
}
