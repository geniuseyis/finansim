import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// [AuthRepository] sözleşmesinin somut implementasyonu.
///
/// Görevi: data source'tan gelen ham [AppUserModel]/[AuthException] sonuçlarını
/// domain'in beklediği `Either<Failure, ...>` tipine çevirmek. Böylece üst
/// katmanlar try-catch ile değil, güvenli Either tipiyle çalışır.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<AppUser?> authStateChanges() => _remoteDataSource.authStateChanges();

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _remoteDataSource.signInWithEmail(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _guard(
      () => _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() {
    return _guard(() => _remoteDataSource.signInWithGoogle());
  }

  @override
  Future<Either<Failure, AppUser>> signInWithApple() {
    return _guard(() => _remoteDataSource.signInWithApple());
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() {
    return _guardUnit(() => _remoteDataSource.deleteAccount());
  }

  @override
  Future<Either<Failure, Unit>> updateDisplayName(String name) {
    return _guardUnit(() => _remoteDataSource.updateDisplayName(name));
  }

  @override
  Future<Either<Failure, Unit>> signOut() {
    return _guardUnit(() => _remoteDataSource.signOut());
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) {
    return _guardUnit(() => _remoteDataSource.sendPasswordResetEmail(email));
  }

  /// [AppUser] döndüren çağrıları try-catch'ten Either'a sarar (DRY).
  Future<Either<Failure, AppUser>> _guard(
    Future<AppUser> Function() action,
  ) async {
    try {
      final user = await action();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(AuthFailure());
    }
  }

  /// Sonuç döndürmeyen çağrıları try-catch'ten Either'a sarar (DRY).
  Future<Either<Failure, Unit>> _guardUnit(
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(AuthFailure());
    }
  }
}
