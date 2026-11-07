import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/services/secure_local_store.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/savings_goal.dart';

/// Hesaplanmış hedef özeti.
class GoalsOverview {
  final List<SavingsGoal> all;

  const GoalsOverview(this.all);

  /// Başlanmış ama tamamlanmamış hedefler.
  List<SavingsGoal> get active => all
      .where((g) => !g.isCompleted && !g.isNotStarted)
      .toList()
    ..sort((a, b) {
      if (a.priority != b.priority) return a.priority ? -1 : 1;
      return b.percent.compareTo(a.percent);
    });

  /// Tamamlanan hedefler.
  List<SavingsGoal> get completed =>
      all.where((g) => g.isCompleted).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Henüz birikim yapılmamış (planlanan) hedefler.
  List<SavingsGoal> get upcoming =>
      all.where((g) => g.isNotStarted).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  /// Aktif + planlanan hedeflerin toplam birikimi.
  double get totalSaved =>
      all.where((g) => !g.isCompleted).fold<double>(0, (s, g) => s + g.saved);

  /// Aktif + planlanan hedeflerin toplam hedef tutarı.
  double get totalTarget =>
      all.where((g) => !g.isCompleted).fold<double>(0, (s, g) => s + g.target);

  /// Genel tamamlanma oranı (0-100).
  int get overallPercent =>
      totalTarget <= 0 ? 0 : ((totalSaved / totalTarget) * 100).round();

  int get totalCount => all.length;
  int get completedCount => completed.length;
}

final goalsBoxProvider = Provider<Box>((ref) {
  ref.watch(currentUidProvider);
  return SecureLocalStore.box(HiveBoxes.goals);
});

/// Hedefleri canlı yayınlar (Hive değişince otomatik güncellenir).
final goalsProvider = StreamProvider<List<SavingsGoal>>((ref) async* {
  final box = ref.watch(goalsBoxProvider);
  List<SavingsGoal> read() =>
      box.values.map((v) => SavingsGoal.fromMap(v as Map)).toList();
  yield read();
  yield* box.watch().map((_) => read());
});

/// Hesaplanmış özet.
final goalsOverviewProvider = Provider<AsyncValue<GoalsOverview>>(
  (ref) => ref.watch(goalsProvider).whenData(GoalsOverview.new),
);

final goalsServiceProvider = Provider<GoalsService>(
  (ref) => GoalsService(ref.watch(goalsBoxProvider)),
);

/// Hedefleri yazıp silen servis.
class GoalsService {
  final Box _box;

  const GoalsService(this._box);

  Future<void> save(SavingsGoal goal) => _box.put(goal.id, goal.toMap());

  Future<void> delete(String id) => _box.delete(id);

  /// Hedefe birikim ekler (negatif de olabilir, 0'ın altına inmez).
  Future<void> addContribution(SavingsGoal goal, double amount) {
    final next = (goal.saved + amount).clamp(0, double.infinity).toDouble();
    return save(goal.copyWith(saved: next));
  }
}
