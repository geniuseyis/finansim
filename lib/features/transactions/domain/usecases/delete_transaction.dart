import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

/// Bir işlemi kimliğine (id) göre silme use case'i.
class DeleteTransaction implements UseCase<Unit, String> {
  final TransactionRepository repository;

  const DeleteTransaction(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String params) {
    return repository.deleteTransaction(params);
  }
}
