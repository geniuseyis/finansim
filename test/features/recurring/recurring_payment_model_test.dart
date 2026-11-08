import 'package:financeapp/features/recurring/domain/recurring_payment.dart';
import 'package:flutter_test/flutter_test.dart';

RecurringPayment payment({
  double amount = 100,
  PaymentFrequency frequency = PaymentFrequency.monthly,
  DateTime? nextDate,
  PaymentStatus status = PaymentStatus.active,
}) =>
    RecurringPayment(
      id: '1',
      title: 'Netflix',
      category: 'Eğlence',
      amount: amount,
      frequency: frequency,
      nextDate: nextDate ?? DateTime(2026, 1, 15),
      status: status,
    );

void main() {
  group('RecurringPayment', () {
    test('aylık karşılık sıklığa göre hesaplanır', () {
      expect(payment(amount: 120, frequency: PaymentFrequency.yearly).monthlyAmount, 10);
      expect(payment(amount: 30, frequency: PaymentFrequency.quarterly).monthlyAmount, 10);
      expect(payment(amount: 12, frequency: PaymentFrequency.weekly).monthlyAmount, 52);
    });
  });
}
