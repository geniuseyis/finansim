import 'package:financeapp/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('varsayılan mesajlar dolu', () {
      for (final f in const <Failure>[ServerFailure(), CacheFailure(), NetworkFailure(), AuthFailure()]) {
        expect(f.message, isNotEmpty);
      }
    });

    test('aynı tür ve mesaj eşittir', () {
      expect(const AuthFailure('x'), const AuthFailure('x'));
      expect(const AuthFailure('x'), isNot(const AuthFailure('y')));
    });

    test('farklı türler eşit değildir', () {
      expect(const ServerFailure('x'), isNot(const CacheFailure('x')));
    });
  });
}
