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

    test('aktif ödemeler tarihe göre sıralanır', () {
      final o = RecurringOverview([p('geç', 9), p('erken', 1)]);
      expect(o.active.first.id, 'erken');
    });

    test('yaklaşanlar 7 günle sınırlı', () {
      final o = RecurringOverview([p('bugün', 0), p('sınır', 7), p('uzak', 8)]);
      expect(o.upcoming.map((e) => e.id), ['bugün', 'sınır']);
    });

    test('gecikmiş ödeme yaklaşan sayılmaz', () {
      expect(RecurringOverview([p('geçmiş', -1)]).upcoming, isEmpty);
    });
  });
}
