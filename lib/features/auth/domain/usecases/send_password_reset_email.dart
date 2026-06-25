import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Şifre sıfırlama e-postası gönderme use case'i.
/// Parametre olarak hedef e-posta adresini alır.
class SendPasswordResetEmail implements UseCase<Unit, String> {
  final AuthRepository repository;

  const SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}
