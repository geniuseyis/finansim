import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Tüm use case'lerin uyacağı ortak sözleşme (contract).
///
/// - [SuccessType] : işlem başarılı olduğunda dönecek sonucun tipi.
/// - [Params]      : use case'in çalışmak için ihtiyaç duyduğu girdiler.
///
/// Her use case `call` ile çağrılır ve `Either<Failure, SuccessType>` döner:
///   - `Left(Failure)`     → işlem başarısız (hata bilgisini taşır)
///   - `Right(SuccessType)` → işlem başarılı (sonucu taşır)
///
/// `call` özel bir Dart metodudur; sınıfı fonksiyon gibi çağırmayı sağlar:
///   `final result = await loginUser(params);`
abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

/// Hiçbir girdi gerektirmeyen use case'ler için boş parametre nesnesi.
///
/// Örn. "çıkış yap" use case'i bir parametre almaz; ama [UseCase] imzası
/// daima bir [Params] beklediği için onun yerine [NoParams] geçeriz.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
