import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_category.dart';
import 'transaction_providers.dart';

/// İstatistik ekranındaki dönem seçimi.
enum StatsPeriod { day, week, month, year }

/// Bir dönemin [start, end) aralığı ve karşılaştırılan önceki dönemin başı.
typedef PeriodWindow = ({DateTime start, DateTime end, DateTime previousStart});

extension StatsPeriodWindow on StatsPeriod {
  /// [now] anının içinde bulunduğu dönem. Hafta, bugün dahil son 7 gündür.
  PeriodWindow window(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      StatsPeriod.day => (
          start: today,
          end: today.add(const Duration(days: 1)),
          previousStart: today.subtract(const Duration(days: 1)),
        ),
      StatsPeriod.week => (
          start: today.subtract(const Duration(days: 6)),
          end: today.add(const Duration(days: 1)),
          previousStart: today.subtract(const Duration(days: 13)),
        ),
      StatsPeriod.month => (
          start: DateTime(now.year, now.month),
          end: DateTime(now.year, now.month + 1),
          previousStart: DateTime(now.year, now.month - 1),
        ),
      StatsPeriod.year => (
          start: DateTime(now.year),
          end: DateTime(now.year + 1),
          previousStart: DateTime(now.year - 1),
        ),
    };
  }
}

/// Günlük trend grafiği için tek bir nokta.
class DayPoint {
  final String label;
  final double value;
  const DayPoint(this.label, this.value);
}

/// Gerçek işlemlerden türetilen finansal özet.
///
/// Dashboard ve İstatistikler ekranları bu özeti kullanır; böylece her iki
/// ekran da canlı (Hive) veriyle çalışır.
class FinanceSummary {
  final List<AppTransaction> all;
  final double income;
  final double expense;
  final double investment;
  final double incomeChange;
  final double expenseChange;
  final double netChange;
  final double investmentChange;
  final Map<TransactionCategory, double> expenseByCategory;

  const FinanceSummary({
    required this.all,
    required this.income,
    required this.expense,
    required this.investment,
    required this.incomeChange,
    required this.expenseChange,
    required this.netChange,
    required this.investmentChange,
    required this.expenseByCategory,
  });

  double get balance => income - expense;
  double get net => income - expense;
  int get count => all.length;

  /// En yeni [n] işlem (liste zaten yeniden eskiye sıralı).
  List<AppTransaction> recent(int n) => all.take(n).toList();

  /// Son [days] günün, türe göre (veya tümü) günlük toplamı.
  List<DayPoint> dailyTrend(int days, {TransactionType? type}) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    return [
      for (var i = days - 1; i >= 0; i--)
        () {
          final day = base.subtract(Duration(days: i));
          final total = all
              .where((t) =>
                  (type == null || t.type == type) &&
                  t.date.year == day.year &&
                  t.date.month == day.month &&
                  t.date.day == day.day)
              .fold<double>(0, (s, t) => s + t.amount);
          return DayPoint('${day.day}.${day.month}', total);
        }(),
    ];
  }

  /// Yalnızca [period] içindeki işlemlerden özet çıkarır; değişim yüzdeleri
  /// aynı uzunluktaki bir önceki dönemle karşılaştırılır.
  factory FinanceSummary.forPeriod(
    List<AppTransaction> all,
    StatsPeriod period, {
    DateTime? now,
  }) {
    final w = period.window(now ?? DateTime.now());
    bool inCurrent(AppTransaction t) =>
        !t.date.isBefore(w.start) && t.date.isBefore(w.end);
    bool inPrevious(AppTransaction t) =>
        !t.date.isBefore(w.previousStart) && t.date.isBefore(w.start);

    final current = all.where(inCurrent).toList();
    final previous = all.where(inPrevious).toList();

    double total(List<AppTransaction> list, bool Function(AppTransaction) test) =>
        list.where(test).fold<double>(0, (s, t) => s + t.amount);
    bool isIncome(AppTransaction t) => t.type == TransactionType.income;
    bool isExpense(AppTransaction t) => t.type == TransactionType.expense;
    bool isInvestment(AppTransaction t) =>
        t.category == TransactionCategory.investment;

    double change(double cur, double prev) {
      if (prev == 0) return cur > 0 ? 100 : 0;
      return (cur - prev) / prev.abs() * 100;
    }

    final byCategory = <TransactionCategory, double>{};
    for (final t in current.where(isExpense)) {
      byCategory.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }

    final income = total(current, isIncome);
    final expense = total(current, isExpense);
    final investment = total(current, isInvestment);
    final prevIncome = total(previous, isIncome);
    final prevExpense = total(previous, isExpense);

    return FinanceSummary(
      all: current,
      income: income,
      expense: expense,
      investment: investment,
      incomeChange: change(income, prevIncome),
      expenseChange: change(expense, prevExpense),
      netChange: change(income - expense, prevIncome - prevExpense),
      investmentChange: change(investment, total(previous, isInvestment)),
      expenseByCategory: byCategory,
    );
  }

  factory FinanceSummary.from(List<AppTransaction> all) {
    var income = 0.0;
    var expense = 0.0;
    var investment = 0.0;
    final byCategory = <TransactionCategory, double>{};

    for (final t in all) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
        byCategory.update(t.category, (v) => v + t.amount,
            ifAbsent: () => t.amount);
      }
      if (t.category == TransactionCategory.investment) {
        investment += t.amount;
      }
    }

    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    bool inThisMonth(DateTime d) => d.year == now.year && d.month == now.month;
    bool inLastMonth(DateTime d) =>
        d.year == lastMonth.year && d.month == lastMonth.month;

    double sumWhere(bool Function(AppTransaction) test) =>
        all.where(test).fold<double>(0, (s, t) => s + t.amount);

    double changeOf(bool Function(AppTransaction) base) {
      final current = sumWhere((t) => base(t) && inThisMonth(t.date));
      final previous = sumWhere((t) => base(t) && inLastMonth(t.date));
      if (previous == 0) return current > 0 ? 100 : 0;
      return (current - previous) / previous * 100;
    }

    final incomeChange = changeOf((t) => t.type == TransactionType.income);
    final expenseChange = changeOf((t) => t.type == TransactionType.expense);
    final investmentChange =
        changeOf((t) => t.category == TransactionCategory.investment);

    // Net değişim: bu ay net - geçen ay net.
    final incomeThis =
        sumWhere((t) => t.type == TransactionType.income && inThisMonth(t.date));
    final expenseThis = sumWhere(
        (t) => t.type == TransactionType.expense && inThisMonth(t.date));
    final incomeLast =
        sumWhere((t) => t.type == TransactionType.income && inLastMonth(t.date));
    final expenseLast = sumWhere(
        (t) => t.type == TransactionType.expense && inLastMonth(t.date));
    final netThis = incomeThis - expenseThis;
    final netLast = incomeLast - expenseLast;
    final netChange = netLast == 0
        ? (netThis > 0 ? 100.0 : 0.0)
        : (netThis - netLast) / netLast.abs() * 100;

    return FinanceSummary(
      all: all,
      income: income,
      expense: expense,
      investment: investment,
      incomeChange: incomeChange,
      expenseChange: expenseChange,
      netChange: netChange,
      investmentChange: investmentChange,
      expenseByCategory: byCategory,
    );
  }
}

/// İşlem akışından türetilen, canlı finans özeti sağlayıcısı.
final financeSummaryProvider = Provider<AsyncValue<FinanceSummary>>((ref) {
  return ref
      .watch(transactionsStreamProvider)
      .whenData(FinanceSummary.from);
});
