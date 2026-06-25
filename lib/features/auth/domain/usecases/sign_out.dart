import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Oturumu kapatma use case'i. Girdi gerektirmez, başarıda [Unit] döner.
class SignOut implements UseCase<Unit, NoParams> {
  final AuthRepository repository;

  const SignOut(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.signOut();
  }
}
