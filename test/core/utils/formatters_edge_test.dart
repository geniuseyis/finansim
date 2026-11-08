import 'package:financeapp/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => Formatters.setCurrencySymbol('₺'));

  group('Formatters sınır durumları', () {
    test('para birimi sembolü değişir', () {
      Formatters.setCurrencySymbol('\$');
      expect(Formatters.currency(10), contains('\$'));
    });

    test('küçük tutar kuruşsuz yazılır', () {
      expect(Formatters.compactCurrency(12450), contains('12.450'));
      expect(Formatters.compactCurrency(12450), isNot(contains(',')));
    });
    test('yüzde işareti ayrı, virgüllü', () {
      expect(Formatters.percent(-12.5), '%12,50');
    });
  });
}
