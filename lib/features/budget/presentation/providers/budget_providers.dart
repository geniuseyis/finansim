import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Tek bir kategori bütçesi: limit + bu ayki harcama.
class BudgetItem {
  final TransactionCategory category;
  final double limit;
  final double spent;

  const BudgetItem({
    required this.category,
    required this.limit,
    required this.spent,
  });

  double get remaining => limit - spent;
  int get usagePercent =>
      limit <= 0 ? 0 : ((spent / limit) * 100).clamp(0, 999).round();
  int sharePercent(double totalBudget) =>
      totalBudget <= 0 ? 0 : ((limit / totalBudget) * 100).round();
}

/// Tüm bütçe görünümü.
class BudgetOverview {
  final List<BudgetItem> items;
  final double totalBudget;
  final double totalSpent;

  const BudgetOverview({
    required this.items,
    required this.totalBudget,
    required this.totalSpent,
  });

  double get remaining => totalBudget - totalSpent;
  int get usagePercent =>
      totalBudget <= 0 ? 0 : ((totalSpent / totalBudget) * 100).round();
  bool get isEmpty => items.isEmpty;
}

/// Bütçe limitlerinin tutulduğu Hive kutusu.
final budgetBoxProvider = Provider<Box>(
  (ref) => Hive.box(HiveBoxes.budgets),
);

/// Kategori → limit eşlemesini canlı olarak yayınlar.
final budgetsProvider = StreamProvider<Map<TransactionCategory, double>>(
  (ref) async* {
    final box = ref.watch(budgetBoxProvider);

    Map<TransactionCategory, double> read() {
      final result = <TransactionCategory, double>{};
      for (final key in box.keys) {
        final category = TransactionCategory.values
            .where((c) => c.name == key)
            .firstOrNull;
        final value = box.get(key);
        if (category != null && value is num) {
          result[category] = value.toDouble();
        }
      }
      return result;
    }

    yield read();
    yield* box.watch().map((_) => read());
  },
);

/// Bütçe limitlerini ve bu ayki gerçek harcamayı birleştiren genel görünüm.
final budgetOverviewProvider = Provider<AsyncValue<BudgetOverview>>((ref) {
  final budgetsAsync = ref.watch(budgetsProvider);
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];

  return budgetsAsync.whenData((budgets) {
    final now = DateTime.now();
    final spentByCategory = <TransactionCategory, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        spentByCategory.update(t.category, (v) => v + t.amount,
            ifAbsent: () => t.amount);
      }
    }

    final items = budgets.entries
        .map((e) => BudgetItem(
              category: e.key,
              limit: e.value,
              spent: spentByCategory[e.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.limit.compareTo(a.limit));

    final totalBudget = budgets.values.fold<double>(0, (s, v) => s + v);
    final totalSpent = items.fold<double>(0, (s, i) => s + i.spent);

    return BudgetOverview(
      items: items,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
    );
  });
});

/// Bütçe limitlerini yazıp silen servis.
class BudgetService {
  final Box _box;

  const BudgetService(this._box);

  Future<void> setBudget(TransactionCategory category, double limit) =>
      _box.put(category.name, limit);

  Future<void> removeBudget(TransactionCategory category) =>
      _box.delete(category.name);
}

final budgetServiceProvider = Provider<BudgetService>(
  (ref) => BudgetService(ref.watch(budgetBoxProvider)),
);
