import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Google hesabı ile giriş yapma use case'i. Girdi gerektirmez.
class SignInWithGoogle implements UseCase<AppUser, NoParams> {
  final AuthRepository repository;

  const SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
