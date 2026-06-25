import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';

/// [TransactionRepository] sözleşmesinin Hive tabanlı implementasyonu.
///
/// Yazma işlemlerinde [CacheException]'ı `Either<Failure, Unit>`'e çevirir;
/// okuma akışını ise doğrudan üst katmana geçirir.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;

  const TransactionRepositoryImpl(this._localDataSource);

  @override
  Stream<List<AppTransaction>> watchTransactions() {
    return _localDataSource.watchTransactions();
  }

  @override
  Future<Either<Failure, Unit>> addTransaction(AppTransaction transaction) {
    return _guard(
      () => _localDataSource.addTransaction(
        TransactionModel.fromEntity(transaction),
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction(AppTransaction transaction) {
    return _guard(
      () => _localDataSource.updateTransaction(
        TransactionModel.fromEntity(transaction),
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) {
    return _guard(() => _localDataSource.deleteTransaction(id));
  }

  /// Yazma çağrılarını try-catch'ten Either'a sarar (DRY).
  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
