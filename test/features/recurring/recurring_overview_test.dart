import 'package:financeapp/features/recurring/domain/recurring_payment.dart';
import 'package:financeapp/features/recurring/presentation/providers/recurring_providers.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.now();
DateTime _day(int offset) => DateTime(_now.year, _now.month, _now.day + offset);

RecurringPayment p(
  String id,
  int offset, {
  double amount = 100,
  PaymentStatus status = PaymentStatus.active,
}) =>
    RecurringPayment(
      id: id,
      title: id,
      category: '',
      amount: amount,
      frequency: PaymentFrequency.monthly,
      nextDate: _day(offset),
      status: status,
    );

void main() {
  group('RecurringOverview', () {
    test('durdurulan ödeme aktif sayılmaz', () {
      final o = RecurringOverview([p('a', 1), p('b', 2, status: PaymentStatus.paused)]);
      expect(o.activeCount, 1);
    });
  });
}
