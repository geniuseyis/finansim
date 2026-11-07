import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Hesabı kalıcı olarak silme use case'i. Şifreli hesaplarda yeniden
/// doğrulama için şifre alır; Google/Apple hesaplarında `null` verilir.
class DeleteAccount implements UseCase<Unit, String?> {
  final AuthRepository repository;

  const DeleteAccount(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String? password) {
    return repository.deleteAccount(password: password);
  }
}
