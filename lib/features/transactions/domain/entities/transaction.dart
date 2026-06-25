import 'package:equatable/equatable.dart';

import 'transaction_category.dart';

/// İşlemin türü: gelir mi gider mi.
enum TransactionType { income, expense }

/// Tek bir finansal işlemi (gelir veya gider) temsil eden domain varlığı.
///
/// `Transaction` adı `cloud_firestore` ile çakışmasın diye [AppTransaction]
/// adını kullanırız. Sınıf saf Dart'tır; Hive/Firebase bilmez.
class AppTransaction extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? note;

  const AppTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  /// İşlemin bakiyeye etkisi (gelir +, gider -). Hesaplamalarda kolaylık sağlar.
  double get signedAmount => type == TransactionType.income ? amount : -amount;

  /// Bazı alanları değiştirerek kopya üretir (immutable güncelleme).
  AppTransaction copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
  }) {
    return AppTransaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, type, category, date, note];
}
