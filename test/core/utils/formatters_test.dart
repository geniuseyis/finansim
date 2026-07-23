import 'package:financeapp/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    setUp(() => Formatters.setCurrencySymbol('₺'));

    test('currency biçimlendirmesi Türkçe formatta', () {
      expect(Formatters.currency(1250), '₺1.250,00');
      expect(Formatters.currency(0), '₺0,00');
    });

    test('setCurrencySymbol sembolü değiştirir', () {
      Formatters.setCurrencySymbol('\$');
      expect(Formatters.currency(1250).startsWith('\$'), isTrue);
      Formatters.setCurrencySymbol('₺');
    });

    test('amount sembolsüz sayı döndürür', () {
      expect(Formatters.amount(1250.5), '1.250,50');
    });

    test('percent iki ondalık + virgül', () {
      expect(Formatters.percent(12.5), '%12,50');
      expect(Formatters.percent(-3.2), '%3,20');
    });

    test('date gg.aa.yyyy', () {
      expect(Formatters.date(DateTime(2026, 7, 23)), '23.07.2026');
    });
  });
}
