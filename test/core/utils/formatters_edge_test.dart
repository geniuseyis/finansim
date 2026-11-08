import 'package:financeapp/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => Formatters.setCurrencySymbol('₺'));

  group('Formatters sınır durumları', () {
    test('para birimi sembolü değişir', () {
      Formatters.setCurrencySymbol('\$');
      expect(Formatters.currency(10), contains('\$'));
    });
  });
}
