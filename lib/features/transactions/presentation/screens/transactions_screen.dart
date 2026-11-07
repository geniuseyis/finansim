import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../../domain/entities/transaction.dart';
import '../extensions/category_ui.dart';
import '../providers/transaction_filter_provider.dart';
import '../providers/transaction_providers.dart';

/// İşlem listesi filtresi.
enum _TxnFilter { all, income, expense }

/// Ekran 13 — İşlemler. Gerçek (Hive) işlemleri tarihe göre gruplar.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  _TxnFilter _filter = _TxnFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(AppTransaction t) {
    switch (_filter) {
      case _TxnFilter.all:
        return true;
      case _TxnFilter.income:
        return t.type == TransactionType.income;
      case _TxnFilter.expense:
        return t.type == TransactionType.expense;
    }
  }

  bool _matchesQuery(AppTransaction t) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return t.title.toLowerCase().contains(q) ||
        t.category.label.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final txnsAsync = ref.watch(transactionsStreamProvider);
    final advanced = ref.watch(transactionFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
      ),
      body: SafeArea(
        bottom: false,
        child: txnsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (all) {
            final filtered = all
                .where((t) =>
                    _matchesFilter(t) && _matchesQuery(t) && advanced.matches(t))
                .toList();
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    0,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _Header(
                        onBell: () => context.push(AppRoutes.notifications),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SearchRow(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        onFilter: () => context.push(AppRoutes.searchFilter),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FilterTabs(
                        filter: _filter,
                        onChanged: (f) => setState(() => _filter = f),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (advanced.isActive) ...[
                        _ActiveFilterBar(
                          count: filtered.length,
                          onClear: () => ref
                              .read(transactionFilterProvider.notifier)
                              .clear(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      _SummaryCard(transactions: all),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  ..._buildGroups(filtered),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    120,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _MonthSummary(
                      count: all.length,
                      onReport: () => context.push(AppRoutes.statistics),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildGroups(List<AppTransaction> txns) {
    // Tarihe (gün) göre grupla; liste zaten yeniden eskiye sıralı.
    final groups = <DateTime, List<AppTransaction>>{};
    for (final t in txns) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(key, () => []).add(t);
    }
    return [
      for (final entry in groups.entries)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: _DateGroup(date: entry.key, transactions: entry.value),
          ),
        ),
    ];
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBell;

  const _Header({required this.onBell});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sekmeden açılınca geri yok; başlık sola yaslanır (HIG büyük başlık).
        if (context.canPop()) ...[
          const AppBackButton(),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İşlemler',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tüm finansal hareketlerini görüntüle',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onBell,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 28),
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveFilterBar extends StatelessWidget {
  final int count;
  final VoidCallback onClear;

  const _ActiveFilterBar({required this.count, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text('Gelişmiş filtre aktif · $count sonuç',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Row(
              children: [
                Icon(Icons.close, size: 16, color: AppColors.primary),
                SizedBox(width: 2),
                Text('Temizle',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'İşlem ara...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onFilter,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.tune, size: 18, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Filtrele',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _TxnFilter filter;
  final ValueChanged<_TxnFilter> onChanged;

  const _FilterTabs({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _tab(_TxnFilter.all, Icons.grid_view_rounded, 'Tümü', AppColors.primary),
          _tab(_TxnFilter.income, Icons.north_east, 'Gelir', AppColors.success),
          _tab(_TxnFilter.expense, Icons.south_east, 'Gider', AppColors.error),
        ],
      ),
    );
  }

  Widget _tab(_TxnFilter value, IconData icon, String label, Color color) {
    final active = filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: active ? color : AppColors.textSecondary),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<AppTransaction> transactions;

  const _SummaryCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    var income = 0.0;
    var expense = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    final net = income - expense;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _col('Toplam Gelir', Formatters.currency(income), AppColors.success,
                '↑ %8,21'),
            _divider(),
            _col('Toplam Gider', Formatters.currency(expense), AppColors.error,
                '↑ %3,65'),
            _divider(),
            _col('Net Bakiye', Formatters.currency(net), AppColors.primary,
                '↑ %12,45'),
            _divider(),
            _col('İşlem Sayısı', '${transactions.length}',
                AppColors.textPrimary, 'Bu ay', plain: true),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.md);

  Widget _col(String title, String value, Color color, String sub,
      {bool plain = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            sub,
            style: TextStyle(
              color: plain ? AppColors.textSecondary : color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  final DateTime date;
  final List<AppTransaction> transactions;

  const _DateGroup({required this.date, required this.transactions});

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Bugün, ${Formatters.longDate(date)}';
    if (diff == 1) return 'Dün, ${Formatters.longDate(date)}';
    return Formatters.longDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final dailyNet = transactions.fold<double>(
      0,
      (sum, t) => sum + t.signedAmount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${dailyNet >= 0 ? '+' : '-'}${Formatters.currency(dailyNet.abs())}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: dailyNet >= 0
                      ? AppColors.success
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              for (var i = 0; i < transactions.length; i++) ...[
                _TxnRow(transaction: transactions[i]),
                if (i != transactions.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TxnRow extends StatelessWidget {
  final AppTransaction transaction;

  const _TxnRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = transaction.category.color;

    return InkWell(
      onTap: () =>
          context.push(AppRoutes.transactionDetail, extra: transaction),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(transaction.category.icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.category.label} • '
                    '${Formatters.time(transaction.date)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${Formatters.currency(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.success : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final int count;
  final VoidCallback onReport;

  const _MonthSummary({required this.count, required this.onReport});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return AppCard(
      onTap: onReport,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_outlined,
                color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Formatters.longDate(now).split(' ').sublist(1).join(' ')} Özeti',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$count işlem',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Row(
            children: [
              Icon(Icons.insights, size: 18, color: AppColors.primary),
              SizedBox(width: AppSpacing.xxs),
              Text(
                'Raporu Görüntüle',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Henüz işlem yok',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Yeni bir gelir veya gider eklemek için + butonuna dokun.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
