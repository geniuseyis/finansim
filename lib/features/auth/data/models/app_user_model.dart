import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

/// [AppUser] varlığının data katmanındaki karşılığı.
///
/// Firebase'in [User] nesnesini domain'in tanıdığı [AppUser]'a dönüştürür.
/// `data` katmanı Firebase'i bilir; domain bilmez — dönüşüm burada olur.
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.hasPassword,
  });

  /// Firebase [User] nesnesinden bir [AppUserModel] üretir.
  factory AppUserModel.fromFirebaseUser(User user) {
    return AppUserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      hasPassword: user.providerData.any((p) => p.providerId == 'password'),
    );
  }
}
