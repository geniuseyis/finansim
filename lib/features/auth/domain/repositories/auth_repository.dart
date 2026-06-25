import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

/// Kimlik doğrulama işlemlerinin domain katmanındaki sözleşmesi (contract).
///
/// `presentation` ve `domain` katmanları yalnızca bu soyutlamayı tanır;
/// somut Firebase implementasyonu `data` katmanındadır. Bu, Bağımlılığın
/// Ters Çevrilmesi (Dependency Inversion) prensibinin uygulanışıdır.
abstract interface class AuthRepository {
  /// Oturum durumundaki değişiklikleri yayınlayan akış (stream).
  /// Kullanıcı giriş yapınca [AppUser], çıkış yapınca `null` yayınlar.
  Stream<AppUser?> authStateChanges();

  /// E-posta ve şifre ile giriş yapar.
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// E-posta ve şifre ile yeni hesap oluşturur.
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Google hesabı ile giriş yapar.
  Future<Either<Failure, AppUser>> signInWithGoogle();

  /// Oturumu kapatır.
  Future<Either<Failure, Unit>> signOut();

  /// Verilen e-postaya şifre sıfırlama bağlantısı gönderir.
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);
}
