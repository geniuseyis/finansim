import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transaction_filter.dart';

/// İşlemler ekranına uygulanan aktif gelişmiş filtreyi tutar.
///
/// Arama & Filtre ekranı "Filtrele"ye basınca [set] ile güncellenir; İşlemler
/// ekranı bu filtreyi listeye uygular.
class TransactionFilterController extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => TransactionFilter.empty;

  void set(TransactionFilter filter) => state = filter;

  void clear() => state = TransactionFilter.empty;
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterController, TransactionFilter>(
        TransactionFilterController.new);
