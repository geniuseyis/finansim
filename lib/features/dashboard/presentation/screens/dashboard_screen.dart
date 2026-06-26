import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transaction_list_item.dart';

/// Uygulamanın ana ekranı.
///
/// Faz 4: işlem listesi + ekle/düzenle/sil. Faz 5'te üstüne bakiye özeti ve
/// grafikler eklenecek.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppTransaction transaction,
  ) async {
    await ref
        .read(transactionControllerProvider.notifier)
        .delete(transaction.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finans Takip'),
        actions: [
          IconButton(
            tooltip: 'Biyometrik ekran (önizleme)',
            icon: const Icon(Icons.fingerprint),
            onPressed: () => context.push(AppRoutes.biometric),
          ),
          IconButton(
            tooltip: 'Çıkış yap',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addTransaction),
        icon: const Icon(Icons.add),
        label: const Text('İşlem Ekle'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Hata: $error')),
        data: (transactions) {
          if (transactions.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Dismissible(
                key: ValueKey(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDeleteDialog(context),
                onDismissed: (_) => _confirmDelete(context, ref, transaction),
                child: TransactionListItem(
                  transaction: transaction,
                  onTap: () => context.push(
                    AppRoutes.addTransaction,
                    extra: transaction,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlemi sil'),
        content: const Text('Bu işlemi silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Hiç işlem yokken gösterilen boş durum.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 72,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('Henüz işlem yok', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'İlk gelir veya giderini eklemek için + butonuna dokun.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
