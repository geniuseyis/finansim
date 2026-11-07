import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
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

  void _showTools(BuildContext context) {
    final tools = <(IconData, String, String)>[
      (Icons.currency_exchange, 'Döviz Kurları', AppRoutes.exchangeRates),
      (Icons.swap_horiz, 'Döviz Çevirici', AppRoutes.converter),
      (Icons.document_scanner_outlined, 'Makbuz Okuyucu', AppRoutes.ocr),
      (Icons.smart_toy_outlined, 'Yapay Zeka Önerileri', AppRoutes.aiAdvisor),
      (Icons.event_repeat, 'Tekrarlayan Ödemeler', AppRoutes.recurring),
      (Icons.track_changes, 'Hedeflerim', AppRoutes.goals),
      (Icons.insights, 'İstatistikler', AppRoutes.statistics),
      (Icons.grid_view_rounded, 'Kategoriler', AppRoutes.categories),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('Araçlar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final t in tools)
                    ListTile(
                      leading: Icon(t.$1, color: AppColors.primary),
                      title: Text(t.$2),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.push(t.$3);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
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
                  onNotifications: () => context.push(AppRoutes.notifications),
                ),
                const SizedBox(height: AppSpacing.lg),
                BalanceCard(
                  balance: data.totalBalance,
                  changePercent: data.balanceChangePercent,
                ),
                const SizedBox(height: AppSpacing.lg),
                QuickActions(
                  onIncome: () => context.push(
                    AppRoutes.addTransaction,
                    extra: TransactionType.income,
                  ),
                  onExpense: () => context.push(
                    AppRoutes.addTransaction,
                    extra: TransactionType.expense,
                  ),
                  onRates: () => context.push(AppRoutes.exchangeRates),
                  onScan: () => context.push(AppRoutes.ocr),
                  onAll: () => _showTools(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                SummaryGrid(metrics: data.metrics),
                const SizedBox(height: AppSpacing.lg),
                ExpenseChart(
                  spending: data.monthlySpending,
                  changePercent: data.spendingChangePercent,
                  trend: data.spendingTrend,
                  onTap: () => context.push(AppRoutes.statistics),
                ),
                const SizedBox(height: AppSpacing.lg),
                RecentTransactionsCard(
                  transactions: data.recentTransactions,
                  onSeeAll: () => context.go(AppRoutes.transactions),
                  onTap: (item) => context.push(
                    AppRoutes.transactionDetail,
                    extra: item.source,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AiSuggestionCard(
                  suggestion: data.aiSuggestion,
                  onTap: () => context.push(AppRoutes.aiAdvisor),
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
