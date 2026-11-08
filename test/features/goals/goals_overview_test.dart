import 'package:financeapp/features/goals/domain/savings_goal.dart';
import 'package:financeapp/features/goals/presentation/providers/goals_providers.dart';
import 'package:flutter_test/flutter_test.dart';

SavingsGoal g(
  String id, {
  double target = 100,
  double saved = 0,
  bool priority = false,
  int day = 1,
}) =>
    SavingsGoal(
      id: id,
      title: id,
      iconKey: 'car',
      target: target,
      saved: saved,
      priority: priority,
      createdAt: DateTime(2026, 1, day),
    );

void main() {
  group('GoalsOverview', () {
    test('aktif başlanmış ve bitmemiş hedeflerdir', () {
      final o = GoalsOverview([g('a', saved: 10), g('b'), g('c', saved: 100)]);
      expect(o.active.map((e) => e.id), ['a']);
    });

    test('öncelikli hedef öne geçer', () {
      final o = GoalsOverview([g('normal', saved: 90), g('öncelik', saved: 10, priority: true)]);
      expect(o.active.first.id, 'öncelik');
    });
    test('aynı öncelikte ilerleyen öne geçer', () {
      final o = GoalsOverview([g('az', saved: 10), g('çok', saved: 80)]);
      expect(o.active.first.id, 'çok');
    });
  });
}
