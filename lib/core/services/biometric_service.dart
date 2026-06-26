import 'package:local_auth/local_auth.dart';

/// Cihazın biyometrik kimlik doğrulamasını (parmak izi / yüz) saran servis.
///
/// `local_auth` paketini sarmalar; UI katmanı doğrudan pakete değil bu
/// soyutlamaya bağlanır (test ve değiştirilebilirlik kolaylaşır).
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService([LocalAuthentication? localAuth])
      : _localAuth = localAuth ?? LocalAuthentication();

  /// Cihaz biyometri destekliyor ve kullanılabilir durumda mı?
  Future<bool> isAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Biyometrik doğrulamayı başlatır. Başarılıysa `true` döner.
  Future<bool> authenticate({
    String reason = 'Devam etmek için kimliğinizi doğrulayın',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
