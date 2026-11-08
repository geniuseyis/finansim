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
  });
}
