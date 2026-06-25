import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

/// İşlem (gelir/gider) verilerinin domain katmanındaki sözleşmesi.
///
/// `watchTransactions` reaktif bir akış döndürür: yerel veritabanı her
/// değiştiğinde UI otomatik güncellenir (offline-first deneyim).
abstract interface class TransactionRepository {
  /// Tüm işlemleri, değişiklikleri de yansıtan canlı bir akış olarak verir.
  Stream<List<AppTransaction>> watchTransactions();

  Future<Either<Failure, Unit>> addTransaction(AppTransaction transaction);

  Future<Either<Failure, Unit>> updateTransaction(AppTransaction transaction);

  Future<Either<Failure, Unit>> deleteTransaction(String id);
}
