import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Yeni bir işlem (gelir/gider) ekleme use case'i.
class AddTransaction implements UseCase<Unit, AppTransaction> {
  final TransactionRepository repository;

  const AddTransaction(this.repository);

  @override
  Future<Either<Failure, Unit>> call(AppTransaction params) {
    return repository.addTransaction(params);
  }
}
