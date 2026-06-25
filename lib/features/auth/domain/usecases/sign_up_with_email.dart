import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import 'sign_in_with_email.dart';

/// E-posta + şifre ile yeni hesap oluşturma use case'i.
class SignUpWithEmail implements UseCase<AppUser, AuthCredentialsParams> {
  final AuthRepository repository;

  const SignUpWithEmail(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(AuthCredentialsParams params) {
    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
