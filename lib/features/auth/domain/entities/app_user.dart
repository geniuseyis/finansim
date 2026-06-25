import 'package:equatable/equatable.dart';

/// Uygulamanın tanıdığı kullanıcıyı temsil eden domain varlığı (entity).
///
/// Bu sınıf Firebase'i bilmez; saf Dart'tır. Firebase'in `User` nesnesi
/// `data` katmanında bu varlığa dönüştürülür. Böylece domain ve presentation
/// katmanları yarın Firebase'den başka bir servise geçsek bile değişmez.
class AppUser extends Equatable {
  /// Kullanıcının benzersiz kimliği (Firebase UID).
  final String uid;

  /// Kullanıcının e-posta adresi.
  final String email;

  /// Görünen ad (Google ile girişte gelebilir, e-posta girişinde null olabilir).
  final String? displayName;

  /// Profil fotoğrafı URL'i (varsa).
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
