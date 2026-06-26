import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/ai_suggestion_card.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/balance_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/expense_chart.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/summary_grid.dart';

/// Ekran 07 — Ana Sayfa (Dashboard). Premium fintech ana ekranı.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
  }

  String _firstName(WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final display = user?.displayName;
    if (display != null && display.trim().isNotEmpty) {
      return display.trim().split(' ').first;
    }
    final email = user?.email;
    if (email != null && email.contains('@')) {
      final local = email.split('@').first;
      return local.isEmpty ? local : local[0].toUpperCase() + local.substring(1);
    }
    return 'Kullanıcı';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onAdd: () => context.push(AppRoutes.addTransaction),
        onTap: (index) {
          if (index == 4) {
            // Profil ekranı gelene kadar geçici: çıkış.
            ref.read(authControllerProvider.notifier).signOut();
          } else if (index != 0) {
            _soon(context);
          }
        },
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          onRetry: () => ref.invalidate(dashboardDataProvider),
        ),
        data: (data) => SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardHeader(
                  name: _firstName(ref),
                  onNotifications: () => _soon(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                BalanceCard(
                  balance: data.totalBalance,
                  changePercent: data.balanceChangePercent,
                ),
                const SizedBox(height: AppSpacing.lg),
                QuickActions(
                  onIncome: () => context.push(AppRoutes.addTransaction),
                  onExpense: () => context.push(AppRoutes.addTransaction),
                  onTransfer: () => _soon(context),
                  onScan: () => _soon(context),
                  onAll: () => context.push(AppRoutes.statistics),
                ),
                const SizedBox(height: AppSpacing.lg),
                SummaryGrid(metrics: data.metrics),
                const SizedBox(height: AppSpacing.lg),
                ExpenseChart(
                  spending: data.monthlySpending,
                  changePercent: data.spendingChangePercent,
                  trend: data.spendingTrend,
                ),
                const SizedBox(height: AppSpacing.lg),
                RecentTransactionsCard(
                  transactions: data.recentTransactions,
                  onSeeAll: () => _soon(context),
                  onTap: (item) => context.push(
                    AppRoutes.transactionDetail,
                    extra: AppTransaction(
                      id: item.title,
                      title: item.title,
                      amount: item.amount.abs(),
                      type: item.amount >= 0
                          ? TransactionType.income
                          : TransactionType.expense,
                      category: TransactionCategory.shopping,
                      date: DateTime.now(),
                      note: item.subtitle,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AiSuggestionCard(
                  suggestion: data.aiSuggestion,
                  onTap: () => _soon(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56),
          const SizedBox(height: AppSpacing.md),
          const Text('Bir şeyler ters gitti.'),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }
}
