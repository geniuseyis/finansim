import 'package:financeapp/features/goals/domain/savings_goal.dart';
import 'package:flutter_test/flutter_test.dart';

final _goal = SavingsGoal(
  id: 'x',
  title: 'Ev',
  iconKey: 'home',
  target: 1000,
  saved: 250,
  priority: true,
  targetDate: DateTime(2027, 6, 1),
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  group('SavingsGoal Map', () {
    test('Map dönüşümü alanları korur', () {
      final b = SavingsGoal.fromMap(_goal.toMap());
      expect(b.title, 'Ev');
      expect(b.saved, 250);
      expect(b.priority, isTrue);
      expect(b.targetDate, DateTime(2027, 6, 1));
    });

    test('eski kayıtta ikon ve öncelik varsayılan olur', () {
      final map = _goal.toMap()
        ..remove('iconKey')
        ..remove('priority');
      final b = SavingsGoal.fromMap(map);
      expect(b.iconKey, 'other');
      expect(b.priority, isFalse);
    });
  });
}
