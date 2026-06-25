import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Mevcut bir işlemi güncelleme use case'i.
class UpdateTransaction implements UseCase<Unit, AppTransaction> {
  final TransactionRepository repository;

  const UpdateTransaction(this.repository);

  @override
  Future<Either<Failure, Unit>> call(AppTransaction params) {
    return repository.updateTransaction(params);
  }
}
