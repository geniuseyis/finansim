import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// E-posta + şifre ile giriş yapma use case'i.
class SignInWithEmail implements UseCase<AppUser, AuthCredentialsParams> {
  final AuthRepository repository;

  const SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(AuthCredentialsParams params) {
    return repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

/// E-posta + şifre alan use case'lerin ortak parametre nesnesi.
class AuthCredentialsParams extends Equatable {
  final String email;
  final String password;

  /// Yalnızca kayıtta kullanılır; profilde görünen ad.
  final String? displayName;

  const AuthCredentialsParams({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}
