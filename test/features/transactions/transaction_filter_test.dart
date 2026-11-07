import 'package:financeapp/features/transactions/domain/entities/transaction.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction_category.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction_filter.dart';
import 'package:flutter_test/flutter_test.dart';

AppTransaction txn({
  String title = 'Market',
  double amount = 100,
  TransactionType type = TransactionType.expense,
  TransactionCategory category = TransactionCategory.shopping,
  DateTime? date,
}) =>
    AppTransaction(
      id: title,
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date ?? DateTime.now(),
    );

void main() {
  group('TransactionFilter', () {
    test('boş filtre her işleme uyar ve aktif değildir', () {
      const f = TransactionFilter.empty;
      expect(f.isActive, isFalse);
      expect(f.matches(txn()), isTrue);
    });

    test('tür filtresi', () {
      const f = TransactionFilter(type: TransactionType.income);
      expect(f.isActive, isTrue);
      expect(f.matches(txn(type: TransactionType.income)), isTrue);
      expect(f.matches(txn(type: TransactionType.expense)), isFalse);
    });

    test('tutar aralığı', () {
      const f = TransactionFilter(min: 50, max: 200);
      expect(f.matches(txn(amount: 100)), isTrue);
      expect(f.matches(txn(amount: 40)), isFalse);
      expect(f.matches(txn(amount: 250)), isFalse);
    });

    test('kategori filtresi', () {
      const f = TransactionFilter(categories: {TransactionCategory.food});
      expect(f.matches(txn(category: TransactionCategory.food)), isTrue);
      expect(f.matches(txn(category: TransactionCategory.shopping)), isFalse);
    });

    test('arama başlık ve kategori etiketinde çalışır', () {
      const f = TransactionFilter(query: 'market');
      expect(f.matches(txn(title: 'Market Alışverişi')), isTrue);
      expect(f.matches(txn(title: 'Kira')), isFalse);
    });

    test('bugün tarih ön ayarı', () {
      const f = TransactionFilter(date: DatePreset.today);
      expect(f.matches(txn(date: DateTime.now())), isTrue);
      expect(
          f.matches(txn(date: DateTime.now().subtract(const Duration(days: 3)))),
          isFalse);
    });

    test('ödeme yöntemi filtresi', () {
      const f = TransactionFilter(paymentMethod: 'Nakit');
      expect(f.isActive, isTrue);
      expect(f.matches(txn().copyWith(paymentMethod: 'Nakit')), isTrue);
      expect(f.matches(txn().copyWith(paymentMethod: 'Kredi Kartı')), isFalse);
      expect(f.matches(txn()), isFalse);
    });
  });
}
