import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../providers/auth_providers.dart';

/// Kimlik doğrulama eylemlerini (giriş, kayıt, çıkış...) yöneten controller.
///
/// `AsyncNotifier`, yükleniyor/başarı/hata durumlarını tek tipte (`AsyncValue`)
/// taşır. UI bu durumu izleyerek spinner gösterir veya hata mesajı basar.
/// Eylem metotları başarıyı `bool` döndürür; UI buna göre yönlendirme yapar.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Başlangıçta yapılacak bir iş yok; sadece eylemleri barındırır.
  }

  Future<bool> signInWithEmail(String email, String password) {
    final useCase = ref.read(signInWithEmailProvider);
    return _run(
      () => useCase(AuthCredentialsParams(email: email, password: password)),
    );
  }

  Future<bool> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) {
    final useCase = ref.read(signUpWithEmailProvider);
    return _run(
      () => useCase(
        AuthCredentialsParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      ),
    );
  }

  Future<bool> updateDisplayName(String name) {
    final useCase = ref.read(updateDisplayNameProvider);
    return _run(() => useCase(name));
  }

  Future<bool> signInWithApple() {
    final useCase = ref.read(signInWithAppleProvider);
    return _run(() => useCase(const NoParams()));
  }

  /// Hesabı siler. Başarılıysa Firebase oturumu da kapanır.
  Future<bool> deleteAccount() {
    final useCase = ref.read(deleteAccountProvider);
    return _run(() => useCase(const NoParams()));
  }

  Future<bool> signInWithGoogle() {
    final useCase = ref.read(signInWithGoogleProvider);
    return _run(() => useCase(const NoParams()));
  }

  Future<bool> sendPasswordResetEmail(String email) {
    final useCase = ref.read(sendPasswordResetEmailProvider);
    return _run(() => useCase(email));
  }

  Future<void> signOut() async {
    final useCase = ref.read(signOutProvider);
    state = const AsyncLoading();
    await useCase(const NoParams());
    state = const AsyncData(null);
  }

  /// Bir use case'i çalıştırır, durumu günceller ve başarı bilgisini döner.
  /// Either sonucu `fold` ile ele alınır: Left → hata, Right → başarı (DRY).
  Future<bool> _run(Future<dynamic> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
