import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// İşlemleri canlı bir akış olarak dinleme use case'i.
///
/// Sorgu (query) use case'i olduğu ve hata akışı stream üzerinden taşındığı
/// için `Either` yerine doğrudan `Stream` döner.
class WatchTransactions {
  final TransactionRepository repository;

  const WatchTransactions(this.repository);

  Stream<List<AppTransaction>> call() => repository.watchTransactions();
}
