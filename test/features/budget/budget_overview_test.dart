import 'package:financeapp/features/budget/presentation/providers/budget_providers.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction_category.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetItem item(double limit, double spent) => BudgetItem(
      category: TransactionCategory.food,
      limit: limit,
      spent: spent,
    );

void main() {
  group('Bütçe', () {
    test('kullanım yüzdesi hesaplanır', () {
      expect(item(200, 50).usagePercent, 25);
    });

    test('limitsiz bütçede yüzde sıfır', () {
      expect(item(0, 50).usagePercent, 0);
    });

    test('aşımda kalan negatif olur', () {
      expect(item(100, 130).remaining, -30);
    });
    test('kullanım yüzdesi 999 ile sınırlı', () {
      expect(item(1, 5000).usagePercent, 999);
    });

    test('toplam içindeki pay hesaplanır', () {
      expect(item(250, 0).sharePercent(1000), 25);
      expect(item(250, 0).sharePercent(0), 0);
    });

    test('genel görünüm toplamları kullanır', () {
      final o = BudgetOverview(items: [item(100, 40)], totalBudget: 100, totalSpent: 40);
      expect(o.remaining, 60);
      expect(o.usagePercent, 40);
      expect(o.isEmpty, isFalse);
    });
    test('boş görünüm', () {
      const o = BudgetOverview(items: [], totalBudget: 0, totalSpent: 0);
      expect(o.isEmpty, isTrue);
      expect(o.usagePercent, 0);
    });
  });
}
