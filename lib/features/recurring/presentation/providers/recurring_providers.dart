import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/services/secure_local_store.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/recurring_payment.dart';

/// Hesaplanmış tekrarlayan ödeme özeti.
class RecurringOverview {
  final List<RecurringPayment> all;

  const RecurringOverview(this.all);

  List<RecurringPayment> get active =>
      all.where((p) => p.status == PaymentStatus.active).toList()
        ..sort((a, b) => a.nextDate.compareTo(b.nextDate));

  /// 7 gün içinde ödenecek aktif ödemeler.
  List<RecurringPayment> get upcoming =>
      active.where((p) => p.daysLeft >= 0 && p.daysLeft <= 7).toList();

  double get monthlyTotal =>
      active.fold<double>(0, (s, p) => s + p.monthlyAmount);

  int get activeCount => active.length;

  double get upcomingTotal =>
      upcoming.fold<double>(0, (s, p) => s + p.amount);

  RecurringPayment? get next => active.isEmpty ? null : active.first;
}

final recurringBoxProvider = Provider<Box>((ref) {
  ref.watch(currentUidProvider);
  return SecureLocalStore.box(HiveBoxes.recurring);
});

/// Tekrarlayan ödemeleri canlı yayınlar.
final recurringPaymentsProvider = StreamProvider<List<RecurringPayment>>(
  (ref) async* {
    final box = ref.watch(recurringBoxProvider);
    List<RecurringPayment> read() => box.values
        .map((v) => RecurringPayment.fromMap(v as Map))
        .toList()
      ..sort((a, b) => a.nextDate.compareTo(b.nextDate));
    yield read();
    yield* box.watch().map((_) => read());
  },
);

/// Hesaplanmış özet.
final recurringOverviewProvider = Provider<AsyncValue<RecurringOverview>>(
  (ref) => ref
      .watch(recurringPaymentsProvider)
      .whenData(RecurringOverview.new),
);

/// Tekrarlayan ödemeleri yazıp silen servis.
class RecurringService {
  final Box _box;

  const RecurringService(this._box);

  Future<void> save(RecurringPayment payment) =>
      _box.put(payment.id, payment.toMap());

  Future<void> delete(String id) => _box.delete(id);

  /// Ödemeyi işaretle: bir sonraki tarihe ilerlet.
  Future<void> markPaid(RecurringPayment payment) {
    final advanced = payment.copyWith(
      nextDate: payment.frequency.advance(payment.nextDate),
    );
    return save(advanced);
  }
}

final recurringServiceProvider = Provider<RecurringService>(
  (ref) => RecurringService(ref.watch(recurringBoxProvider)),
);
