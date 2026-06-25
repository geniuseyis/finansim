import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/error/exceptions.dart';
import '../models/app_user_model.dart';

/// Kimlik doğrulama için uzak veri kaynağının (Firebase) sözleşmesi.
abstract interface class AuthRemoteDataSource {
  Stream<AppUserModel?> authStateChanges();

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUserModel> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<AppUserModel> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}

/// [AuthRemoteDataSource]'ın Firebase Authentication ile gerçekleşen hali.
///
/// Bu katmanın görevi: Firebase çağrılarını yapmak ve Firebase'in
/// [FirebaseAuthException]'larını uygulamanın [AuthException]'ına çevirmek.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  const AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Stream<AppUserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
          (user) => user == null ? null : AppUserModel.fromFirebaseUser(user),
        );
  }

  @override
  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AppUserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  @override
  Future<AppUserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AppUserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  @override
  Future<AppUserModel> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      // Web'de popup açılır; mobilde (Android/iOS) Firebase'in federated
      // sağlayıcı akışı (tarayıcı sekmesi) kullanılır. Tek API, iki platform.
      final credential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);
      return AppUserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  /// Firebase hata kodlarını kullanıcıya gösterilebilecek Türkçe mesajlara çevirir.
  String _messageFromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı.';
      case 'weak-password':
        return 'Şifre çok zayıf (en az 6 karakter).';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Google girişi iptal edildi.';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
