import 'package:financeapp/features/goals/domain/savings_goal.dart';
import 'package:flutter_test/flutter_test.dart';

SavingsGoal goal({double target = 100, double saved = 0}) => SavingsGoal(
      id: '1',
      title: 'Test',
      iconKey: 'car',
      target: target,
      saved: saved,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('SavingsGoal', () {
    test('percent ve remaining hesaplanır', () {
      final g = goal(target: 100, saved: 40);
      expect(g.percent, 40);
      expect(g.remaining, 60);
    });

    test('isNotStarted birikim yokken true', () {
      expect(goal(saved: 0).isNotStarted, isTrue);
      expect(goal(saved: 10).isNotStarted, isFalse);
    });

    test('isCompleted hedefe ulaşınca true', () {
      expect(goal(target: 100, saved: 100).isCompleted, isTrue);
      expect(goal(target: 100, saved: 120).isCompleted, isTrue);
      expect(goal(target: 100, saved: 99).isCompleted, isFalse);
    });

    test('percent 100 üstünü aşmaz, remaining negatif olmaz', () {
      final g = goal(target: 100, saved: 150);
      expect(g.percent, 100);
      expect(g.remaining, 0);
    });

    test('toMap/fromMap tur oyunu (round-trip)', () {
      final g = goal(target: 500, saved: 250);
      final restored = SavingsGoal.fromMap(g.toMap());
      expect(restored.target, 500);
      expect(restored.saved, 250);
      expect(restored.iconKey, 'car');
    });
  });
}
