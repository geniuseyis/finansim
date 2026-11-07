import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_category.dart';

/// [AppTransaction]'ın data katmanı karşılığı.
///
/// Hive'da TypeAdapter/kod üretimi yerine işlemi düz bir `Map` olarak
/// sakladığımız için, varlık ile Map arasındaki dönüşümü bu sınıf yapar.
/// Map değerleri ilkel tiplerdir (String/num/int) → Firestore'a (Faz 7) de
/// doğal şekilde taşınır.
class TransactionModel extends AppTransaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.category,
    required super.date,
    super.note,
    super.paymentMethod,
  });

  /// Bir domain varlığından model üretir.
  factory TransactionModel.fromEntity(AppTransaction entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      date: entity.date,
      note: entity.note,
      paymentMethod: entity.paymentMethod,
    );
  }

  /// Hive'da saklanacak Map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'paymentMethod': paymentMethod,
    };
  }

  /// Hive'dan okunan Map'ten model üretir.
  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.byName(map['type'] as String),
      category: TransactionCategory.values.byName(map['category'] as String),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
    );
  }
}
