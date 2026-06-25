import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

/// İşlem ekleme/güncelleme/silme eylemlerini yöneten controller.
///
/// Yükleniyor/başarı/hata durumlarını `AsyncValue` ile taşır. Her eylem,
/// UI'ın yönlendirme/geri bildirim yapabilmesi için `bool` (başarı) döndürür.
class TransactionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> add(AppTransaction transaction) {
    return _run(() => ref.read(addTransactionProvider)(transaction));
  }

  Future<bool> updateTransaction(AppTransaction transaction) {
    return _run(() => ref.read(updateTransactionProvider)(transaction));
  }

  Future<bool> delete(String id) {
    return _run(() => ref.read(deleteTransactionProvider)(id));
  }

  /// Either sonucunu `fold` ile ele alır: Left → hata, Right → başarı (DRY).
  Future<bool> _run(Future<dynamic> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, void>(
  TransactionController.new,
);
