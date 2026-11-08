import 'package:financeapp/features/recurring/domain/recurring_payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentFrequency.advance', () {
    test('haftalık 7 gün ekler', () {
      expect(PaymentFrequency.weekly.advance(DateTime(2026, 1, 28)),
          DateTime(2026, 2, 4));
    });
  });
}
