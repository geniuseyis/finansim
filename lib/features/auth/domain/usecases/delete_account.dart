import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Hesabı kalıcı olarak silme use case'i.
class DeleteAccount implements UseCase<Unit, NoParams> {
  final AuthRepository repository;

  const DeleteAccount(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.deleteAccount();
  }
}
