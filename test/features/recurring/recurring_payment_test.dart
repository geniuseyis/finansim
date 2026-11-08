import 'package:financeapp/features/recurring/domain/recurring_payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentFrequency.advance', () {
    test('haftalık 7 gün ekler', () {
      expect(PaymentFrequency.weekly.advance(DateTime(2026, 1, 28)),
          DateTime(2026, 2, 4));
    });

    test('aylık aynı güne geçer', () {
      expect(PaymentFrequency.monthly.advance(DateTime(2026, 3, 15)),
          DateTime(2026, 4, 15));
    });

    test('31 Ocak aylıkta 28 Şubat olur', () {
      expect(PaymentFrequency.monthly.advance(DateTime(2026, 1, 31)),
          DateTime(2026, 2, 28));
    });

    test('artık yılda 31 Ocak 29 Şubat olur', () {
      expect(PaymentFrequency.monthly.advance(DateTime(2028, 1, 31)),
          DateTime(2028, 2, 29));
    });
  });
}
