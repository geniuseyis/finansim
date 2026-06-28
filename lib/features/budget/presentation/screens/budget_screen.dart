import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/presentation/extensions/category_ui.dart';
import '../providers/budget_providers.dart';

/// Ekran 11 — Bütçe Planlayıcısı (gerçek veri: Hive limitleri + bu ayki harcama).
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
  }

  Future<void> _openSheet(BuildContext context, {BudgetItem? existing}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BudgetSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(budgetOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onAdd: () => context.push(AppRoutes.addTransaction),
        onTap: (i) {
          if (i == 0) {
            context.go(AppRoutes.dashboard);
          } else if (i == 1) {
            context.go(AppRoutes.transactions);
          } else if (i == 4) {
            context.push(AppRoutes.profile);
          } else if (i != 3) {
            _soon(context);
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (overview) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  onBack: () => context.pop(),
                  onSettings: () => _soon(context),
                ),
                const SizedBox(height: AppSpacing.md),
                _ActionRow(
                  onMonth: () => _soon(context),
                  onAdd: () => _openSheet(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                _TotalBudgetCard(overview: overview),
                const SizedBox(height: AppSpacing.lg),
                _CategoryBudgetCard(
                  overview: overview,
                  onAdd: () => _openSheet(context),
                  onTapItem: (item) => _openSheet(context, existing: item),
                ),
                if (!overview.isEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _AnalyticsRow(overview: overview),
                ],
                const SizedBox(height: AppSpacing.lg),
                _QuickActions(
                  onAddCategory: () => _openSheet(context),
                  onReport: () => context.push(AppRoutes.statistics),
                  onSoon: () => _soon(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const _TopBar({required this.onBack, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const Expanded(
          child: Center(
            child: Text('Bütçe Planlayıcısı',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
        ),
        IconButton(onPressed: onSettings, icon: const Icon(Icons.tune)),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onMonth;
  final VoidCallback onAdd;

  const _ActionRow({required this.onMonth, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthLabel =
        Formatters.longDate(now).split(' ').sublist(1).join(' ');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onMonth,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(monthLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, size: 18, color: Colors.white),
                SizedBox(width: AppSpacing.xs),
                Text('Bütçe Ekle',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalBudgetCard extends StatelessWidget {
  final BudgetOverview overview;

  const _TotalBudgetCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final percent = overview.usagePercent.clamp(0, 100);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Toplam Bütçe',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: AppSpacing.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(Formatters.currency(overview.totalBudget),
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text('%${overview.usagePercent} ',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
              const Text('Kullanıldı',
                  style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              const Text('Kalan ',
                  style: TextStyle(color: AppColors.textSecondary)),
              Text(Formatters.currency(overview.remaining),
                  style: TextStyle(
                      color: overview.remaining >= 0
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBudgetCard extends StatelessWidget {
  final BudgetOverview overview;
  final VoidCallback onAdd;
  final ValueChanged<BudgetItem> onTapItem;

  const _CategoryBudgetCard({
    required this.overview,
    required this.onAdd,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Kategorilere Göre Bütçe',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              GestureDetector(
                onTap: onAdd,
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 16, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text('Ekle',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (overview.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'Henüz bütçe yok.\n"Bütçe Ekle" ile bir kategoriye limit belirle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            for (var i = 0; i < overview.items.length; i++) ...[
              _CategoryRow(
                item: overview.items[i],
                onTap: () => onTapItem(overview.items[i]),
              ),
              if (i != overview.items.length - 1) const Divider(height: 1),
            ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final BudgetItem item;
  final VoidCallback onTap;

  const _CategoryRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = item.category.color;
    final over = item.spent > item.limit;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.category.icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.category.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                      Text(Formatters.currency(item.spent),
                          style: TextStyle(
                              color: over ? AppColors.error : color,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            '${Formatters.currency(item.limit)} bütçe',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ),
                      Text('%${item.usagePercent}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: (item.usagePercent / 100).clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                          over ? AppColors.error : color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final BudgetOverview overview;

  const _AnalyticsRow({required this.overview});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _DistributionCard(overview: overview)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _SummaryCard(overview: overview)),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  final BudgetOverview overview;

  const _DistributionCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bütçe Dağılımı',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 38,
                    sections: [
                      for (final i in overview.items)
                        PieChartSectionData(
                          value: i.limit,
                          color: i.category.color,
                          title: '%${i.sharePercent(overview.totalBudget)}',
                          radius: 22,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        Formatters.currency(overview.totalBudget)
                            .split(',')
                            .first,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                    const Text('Toplam',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final i in overview.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: i.category.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(i.category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11)),
                  ),
                  Text('%${i.sharePercent(overview.totalBudget)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final BudgetOverview overview;

  const _SummaryCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);
    final period =
        '${Formatters.longDate(first)} - ${Formatters.longDate(last)}';

    final rows = [
      (Icons.account_balance_wallet_outlined, AppColors.primary, 'Toplam Bütçe',
          Formatters.currency(overview.totalBudget)),
      (Icons.trending_up, AppColors.success, 'Toplam Harcama',
          Formatters.currency(overview.totalSpent)),
      (Icons.pie_chart_outline, AppColors.warning, 'Kalan Bütçe',
          Formatters.currency(overview.remaining)),
      (Icons.percent, AppColors.accent, 'Kullanım Oranı',
          '%${overview.usagePercent}'),
      (Icons.calendar_month_outlined, AppColors.accent, 'Dönem', period),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bütçe Özeti',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          for (final r in rows)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: r.$2.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(r.$1, size: 16, color: r.$2),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.$3,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary)),
                        Text(r.$4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onAddCategory;
  final VoidCallback onReport;
  final VoidCallback onSoon;

  const _QuickActions({
    required this.onAddCategory,
    required this.onReport,
    required this.onSoon,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add, AppColors.success, 'Kategori Ekle', onAddCategory),
      (Icons.edit_outlined, AppColors.warning, 'Bütçe Düzenle', onSoon),
      (Icons.copy_outlined, AppColors.primary, 'Geçen Aydan Kopyala', onSoon),
      (Icons.show_chart, AppColors.accent, 'Raporu Görüntüle', onReport),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text('Hızlı İşlemler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        Row(
          children: [
            for (final a in actions)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: a.$4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md, horizontal: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: a.$2.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        children: [
                          Icon(a.$1, color: a.$2, size: 22),
                          const SizedBox(height: AppSpacing.xs),
                          Text(a.$3,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: a.$2,
                                  height: 1.2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Bütçe ekleme/düzenleme alt sayfası.
class _BudgetSheet extends ConsumerStatefulWidget {
  final BudgetItem? existing;

  const _BudgetSheet({this.existing});

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  late TransactionCategory _category;
  final _amountController = TextEditingController();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _category = widget.existing?.category ??
        TransactionCategory.expenseCategories.first;
    if (widget.existing != null) {
      _amountController.text = widget.existing!.limit.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir limit girin.')),
      );
      return;
    }
    await ref.read(budgetServiceProvider).setBudget(_category, amount);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await ref.read(budgetServiceProvider).removeBudget(_category);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_isEditing ? 'Bütçeyi Düzenle' : 'Bütçe Ekle',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.lg),
          const Text('Kategori',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<TransactionCategory>(
            initialValue: _category,
            decoration: const InputDecoration(),
            items: [
              for (final c in TransactionCategory.expenseCategories)
                DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 18, color: c.color),
                      const SizedBox(width: AppSpacing.sm),
                      Text(c.label),
                    ],
                  ),
                ),
            ],
            onChanged: _isEditing
                ? null
                : (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Aylık Limit',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
              prefixText: '₺',
              hintText: '0',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _save,
            child: Text(_isEditing ? 'Güncelle' : 'Kaydet'),
          ),
          if (_isEditing) ...[
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Bütçeyi Sil'),
            ),
          ],
        ],
      ),
    );
  }
}
