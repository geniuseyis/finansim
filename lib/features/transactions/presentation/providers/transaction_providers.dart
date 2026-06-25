import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../data/datasources/transaction_local_data_source.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/watch_transactions.dart';

/// --- DI zinciri: Hive Box → DataSource → Repository → UseCase → UI ---

final transactionBoxProvider = Provider<Box>(
  (ref) => Hive.box(HiveBoxes.transactions),
);

final transactionLocalDataSourceProvider = Provider<TransactionLocalDataSource>(
  (ref) => TransactionLocalDataSourceImpl(ref.watch(transactionBoxProvider)),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(
    ref.watch(transactionLocalDataSourceProvider),
  ),
);

// --- Use case provider'ları ---

final addTransactionProvider = Provider(
  (ref) => AddTransaction(ref.watch(transactionRepositoryProvider)),
);

final updateTransactionProvider = Provider(
  (ref) => UpdateTransaction(ref.watch(transactionRepositoryProvider)),
);

final deleteTransactionProvider = Provider(
  (ref) => DeleteTransaction(ref.watch(transactionRepositoryProvider)),
);

final watchTransactionsProvider = Provider(
  (ref) => WatchTransactions(ref.watch(transactionRepositoryProvider)),
);

/// Tüm işlemleri canlı dinleyen provider. UI bunu izleyerek otomatik güncellenir.
final transactionsStreamProvider = StreamProvider<List<AppTransaction>>(
  (ref) => ref.watch(watchTransactionsProvider).call(),
);
