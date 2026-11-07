import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Apple kimliği ile giriş yapma use case'i.
class SignInWithApple implements UseCase<AppUser, NoParams> {
  final AuthRepository repository;

  const SignInWithApple(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(NoParams params) {
    return repository.signInWithApple();
  }
}
