import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

/// İşlemlerin yerel (offline) veri kaynağının sözleşmesi.
abstract interface class TransactionLocalDataSource {
  /// Kutudaki değişiklikleri de yansıtan canlı işlem akışı.
  Stream<List<TransactionModel>> watchTransactions();

  Future<void> addTransaction(TransactionModel transaction);

  Future<void> updateTransaction(TransactionModel transaction);

  Future<void> deleteTransaction(String id);
}

/// [TransactionLocalDataSource]'ın Hive ile gerçekleşen hali.
///
/// İşlemler, anahtarı `id` olan Map kayıtları olarak tek bir Hive kutusunda
/// tutulur. Okuma sırasında tarihe göre (yeniden eskiye) sıralanır.
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Box _box;

  const TransactionLocalDataSourceImpl(this._box);

  List<TransactionModel> _readAll() {
    final items = _box.values
        .map((value) => TransactionModel.fromMap(value as Map))
        .toList();
    // En yeni işlem en üstte görünsün.
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() async* {
    // Önce mevcut veriyi yay, ardından her değişiklikte yeniden yay.
    yield _readAll();
    yield* _box.watch().map((_) => _readAll());
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _box.put(transaction.id, transaction.toMap());
    } catch (_) {
      throw const CacheException('İşlem kaydedilemedi.');
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _box.put(transaction.id, transaction.toMap());
    } catch (_) {
      throw const CacheException('İşlem güncellenemedi.');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const CacheException('İşlem silinemedi.');
    }
  }
}
