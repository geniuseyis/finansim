/// Form alanları için yeniden kullanılabilir doğrulama (validation) kuralları.
///
/// Tüm formlar aynı kuralları buradan kullanır (DRY). Kurallar UI'dan bağımsız
/// saf fonksiyonlar olduğu için test edilmeleri de kolaydır.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');

  /// E-posta alanını doğrular. Hata varsa mesaj, geçerliyse `null` döner.
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'E-posta gerekli.';
    if (!_emailRegex.hasMatch(text)) return 'Geçerli bir e-posta girin.';
    return null;
  }

  /// Şifre alanını doğrular (en az 6 karakter).
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Şifre gerekli.';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalı.';
    return null;
  }
}
