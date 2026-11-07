import 'package:financeapp/features/transactions/data/models/transaction_model.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction_category.dart';
import 'package:financeapp/features/transactions/presentation/providers/finance_summary_provider.dart';
import 'package:flutter_test/flutter_test.dart';

AppTransaction txn(
  String id,
  DateTime date, {
  double amount = 100,
  TransactionType type = TransactionType.expense,
  TransactionCategory category = TransactionCategory.shopping,
}) =>
    AppTransaction(
      id: id,
      title: id,
      amount: amount,
      type: type,
      category: category,
      date: date,
    );

void main() {
  final now = DateTime(2026, 11, 7, 15);

  group('StatsPeriod.window', () {
    test('hafta bugün dahil son 7 gündür', () {
      final w = StatsPeriod.week.window(now);
      expect(w.start, DateTime(2026, 11, 1));
      expect(w.end, DateTime(2026, 11, 8));
      expect(w.previousStart, DateTime(2026, 10, 25));
    });

    test('ay, ocakta bir önceki yılın aralığına geçer', () {
      final w = StatsPeriod.month.window(DateTime(2026, 1, 10));
      expect(w.start, DateTime(2026, 1));
      expect(w.previousStart, DateTime(2025, 12));
    });
  });

  group('FinanceSummary.forPeriod', () {
    final all = [
      txn('bugün', DateTime(2026, 11, 7, 9), amount: 50),
      txn('maaş', DateTime(2026, 11, 2), amount: 1000,
          type: TransactionType.income, category: TransactionCategory.salary),
      txn('geçen ay', DateTime(2026, 10, 15), amount: 200),
      txn('geçen yıl', DateTime(2025, 6, 1), amount: 999),
    ];

    test('yalnızca dönem içindeki işlemleri toplar', () {
      final day = FinanceSummary.forPeriod(all, StatsPeriod.day, now: now);
      expect(day.expense, 50);
      expect(day.income, 0);
      expect(day.count, 1);

      final month = FinanceSummary.forPeriod(all, StatsPeriod.month, now: now);
      expect(month.expense, 50);
      expect(month.income, 1000);
      expect(month.expenseByCategory[TransactionCategory.shopping], 50);
    });

    test('değişim bir önceki dönemle karşılaştırılır', () {
      final month = FinanceSummary.forPeriod(all, StatsPeriod.month, now: now);
      // Ekim gideri 200, kasım 50 → %-75.
      expect(month.expenseChange, closeTo(-75, 0.001));
      // Önceki dönemde gelir yoksa ve bu dönemde varsa %100 kabul edilir.
      expect(month.incomeChange, 100);
    });
  });

  group('TransactionModel', () {
    test('ödeme yöntemi Map dönüşümünde korunur', () {
      final model = TransactionModel.fromEntity(
        txn('kart', now).copyWith(paymentMethod: 'Kredi Kartı'),
      );
      final back = TransactionModel.fromMap(model.toMap());
      expect(back.paymentMethod, 'Kredi Kartı');
      expect(back, model);
    });

    test('ödeme yöntemi olmayan eski kayıtlar okunabilir', () {
      final map = TransactionModel.fromEntity(txn('eski', now)).toMap()
        ..remove('paymentMethod');
      expect(TransactionModel.fromMap(map).paymentMethod, isNull);
    });
  });
}
