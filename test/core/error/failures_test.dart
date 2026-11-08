import 'package:financeapp/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('varsayılan mesajlar dolu', () {
      for (final f in const <Failure>[ServerFailure(), CacheFailure(), NetworkFailure(), AuthFailure()]) {
        expect(f.message, isNotEmpty);
      }
    });
  });
}
