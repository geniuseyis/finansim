import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Hesabın görünen adını güncelleme use case'i.
class UpdateDisplayName implements UseCase<Unit, String> {
  final AuthRepository repository;

  const UpdateDisplayName(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String name) {
    return repository.updateDisplayName(name);
  }
}
