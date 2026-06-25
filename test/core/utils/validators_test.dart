import 'package:financeapp/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('boş e-posta için hata mesajı döner', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('geçersiz formatta e-posta için hata mesajı döner', () {
      expect(Validators.email('seyit'), isNotNull);
      expect(Validators.email('seyit@'), isNotNull);
      expect(Validators.email('seyit@mail'), isNotNull);
    });

    test('geçerli e-posta için null döner', () {
      expect(Validators.email('seyit@mail.com'), isNull);
      expect(Validators.email('  seyit@mail.com  '), isNull);
    });
  });

  group('Validators.password', () {
    test('boş veya kısa şifre için hata mesajı döner', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
    });

    test('6 karakter ve üzeri şifre için null döner', () {
      expect(Validators.password('123456'), isNull);
    });
  });
}
