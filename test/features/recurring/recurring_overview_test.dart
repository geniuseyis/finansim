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

    test('aylık toplam yalnızca aktifleri toplar', () {
      final o = RecurringOverview([
        p('a', 1, amount: 50),
        p('b', 2, amount: 70),
        p('c', 3, amount: 500, status: PaymentStatus.paused),
      ]);
      expect(o.monthlyTotal, 120);
    });

    test('yaklaşan toplamı uzak ödemeyi katmaz', () {
      final o = RecurringOverview([p('a', 1, amount: 40), p('b', 30, amount: 900)]);
      expect(o.upcomingTotal, 40);
    });

    test('sıradaki ödeme en yakın aktif olandır', () {
      expect(RecurringOverview([p('b', 5), p('a', 2)]).next?.id, 'a');
      expect(const RecurringOverview([]).next, isNull);
    });
  });
}
