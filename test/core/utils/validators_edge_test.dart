import 'package:financeapp/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators sınır durumları', () {
    test('e-posta boşlukları kırpılır', () {
      expect(Validators.email('  a@b.co  '), isNull);
    });
    test('alt alan adı kabul edilir', () {
      expect(Validators.email('a.b-c@mail.example.com.tr'), isNull);
    });

    test('uzantısız alan adı reddedilir', () {
      expect(Validators.email('a@b'), isNotNull);
    });

    test('giriş şifresi 6 karakterde geçer', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('yeni şifre 8 karakterden kısa olamaz', () {
      expect(Validators.newPassword('abc1234'), isNotNull);
      expect(Validators.newPassword('abcd1234'), isNull);
    });
  });
}
