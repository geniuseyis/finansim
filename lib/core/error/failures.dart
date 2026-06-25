import 'package:equatable/equatable.dart';

/// Uygulama genelindeki tüm hata türlerinin ortak atası.
///
/// [Failure] nesneleri `domain` ve `presentation` katmanlarında dolaşır.
/// Böylece arayüz, teknik detaya (Firebase kodu, soket hatası vb.) girmeden
/// "ne tür bir sorun oluştu" bilgisine ulaşır.
abstract class Failure extends Equatable {
  /// Kullanıcıya gösterilebilecek ya da log'lanabilecek açıklayıcı mesaj.
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Uzak veri kaynağı (ör. Cloud Firestore, REST API) kaynaklı hata.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Sunucu hatası oluştu.']);
}

/// Yerel önbellek (ör. Hive, SQLite) kaynaklı hata.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Yerel veriye ulaşılamadı.']);
}

/// İnternet bağlantısı yokken oluşan hata.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'İnternet bağlantısı yok.']);
}

/// Kimlik doğrulama (giriş, kayıt, oturum) kaynaklı hata.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Kimlik doğrulama başarısız oldu.']);
}
