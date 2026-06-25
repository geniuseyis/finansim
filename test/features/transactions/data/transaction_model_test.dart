import 'package:financeapp/features/transactions/data/models/transaction_model.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tModel = TransactionModel(
    id: 'abc-123',
    title: 'Market alışverişi',
    amount: 250.75,
    type: TransactionType.expense,
    category: TransactionCategory.food,
    date: DateTime(2026, 6, 26, 14, 30),
    note: 'haftalık',
  );

  group('TransactionModel', () {
    test('toMap doğru anahtar/değerleri üretir', () {
      final map = tModel.toMap();

      expect(map['id'], 'abc-123');
      expect(map['amount'], 250.75);
      expect(map['type'], 'expense');
      expect(map['category'], 'food');
      expect(map['date'], DateTime(2026, 6, 26, 14, 30).millisecondsSinceEpoch);
    });

    test('fromMap -> toMap çift yönlü dönüşüm veriyi korur', () {
      final restored = TransactionModel.fromMap(tModel.toMap());

      expect(restored, tModel); // Equatable sayesinde içerik karşılaştırması
    });

    test('fromEntity bir AppTransaction\'ı modele çevirir', () {
      final entity = AppTransaction(
        id: 'x',
        title: 'Maaş',
        amount: 1000,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(2026, 1, 1),
      );
      final model = TransactionModel.fromEntity(entity);
      expect(model.toMap()['type'], 'income');
      expect(model.title, 'Maaş');
    });
  });
}
