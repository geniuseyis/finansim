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
    String? displayName,
  });

  Future<AppUserModel> signInWithGoogle();

  Future<AppUserModel> signInWithApple();

  /// Oturumdaki hesabı Firebase'den kalıcı olarak siler.
  Future<void> deleteAccount();

  /// Hesabın görünen adını günceller.
  Future<void> updateDisplayName(String name);

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
    // userChanges, profil güncellemelerini (ör. kayıttan sonra ad) de yayınlar.
    return _firebaseAuth.userChanges().map(
          (user) => user == null ? null : AppUserModel.fromFirebaseUser(user),
        );
  }

  @override
  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 25), onTimeout: _onTimeout);
      return AppUserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  @override
  Future<AppUserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 25), onTimeout: _onTimeout);
      final user = credential.user!;
      final name = displayName?.trim();
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
      }
      return AppUserModel.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
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
  Future<AppUserModel> signInWithApple() async {
    try {
      final provider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final credential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);
      return AppUserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const AuthException('Oturum bulunamadı.');
    try {
      await user.updateDisplayName(name.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const AuthException('Oturum bulunamadı.');
    try {
      await user.delete();
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

  /// Çağrı 25 sn içinde dönmezse zaman aşımı hatası fırlatır (sonsuz beklemeyi
  /// önler — özellikle yavaş emülatör / kötü bağlantıda).
  static Never _onTimeout() => throw const AuthException(
        'Bağlantı zaman aşımına uğradı. İnternet bağlantını kontrol et.',
      );

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
      case 'requires-recent-login':
        return 'Güvenliğin için çıkış yapıp tekrar giriş yaptıktan sonra yeniden dene.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi henüz etkin değil.';
      case 'web-context-canceled':
      case 'canceled':
        return 'Giriş iptal edildi.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
