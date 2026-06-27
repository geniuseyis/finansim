import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';

/// Bir kategori bütçesi (dummy veri).
class _BudgetCategory {
  final String name;
  final IconData icon;
  final Color color;
  final double budget;
  final double spent;
  final int usagePercent;
  final int sharePercent;

  const _BudgetCategory(this.name, this.icon, this.color, this.budget,
      this.spent, this.usagePercent, this.sharePercent);
}

const _categories = <_BudgetCategory>[
  _BudgetCategory('Market & Alışveriş', Icons.shopping_cart_outlined,
      AppColors.success, 8000, 6240, 78, 18),
  _BudgetCategory('Yemek & Restoran', Icons.restaurant_outlined,
      AppColors.warning, 5000, 3850, 77, 11),
  _BudgetCategory('Ulaşım', Icons.directions_bus_outlined, AppColors.primary,
      3000, 2100, 70, 7),
  _BudgetCategory('Eğlence', Icons.sports_esports_outlined, AppColors.accent,
      2500, 1400, 56, 6),
  _BudgetCategory('Faturalar', Icons.home_outlined, AppColors.secondary, 4500,
      4100, 91, 10),
  _BudgetCategory('Diğer', Icons.more_horiz, AppColors.textSecondary, 22000,
      18210, 83, 48),
];

/// Ekran 11 — Bütçe Planlayıcısı (tasarım birebir, dummy veri).
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          } else if (i != 3) {
            _soon(context);
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
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
                onAdd: () => _soon(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _TotalBudgetCard(),
              const SizedBox(height: AppSpacing.lg),
              _CategoryBudgetCard(onSeeAll: () => _soon(context)),
              const SizedBox(height: AppSpacing.lg),
              const _AnalyticsRow(),
              const SizedBox(height: AppSpacing.lg),
              _QuickActions(onAction: (_) => _soon(context)),
            ],
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
            child: Text(
              'Bütçe Planlayıcısı',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
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
            child: const Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16),
                SizedBox(width: AppSpacing.xs),
                Text('Mayıs 2025',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Icon(Icons.keyboard_arrow_down, size: 18),
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
  const _TotalBudgetCard();

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      Formatters.currency(45000),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800),
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
              const Text('%78 ',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
              const Text('Kullanıldı',
                  style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              const Text('Kalan ',
                  style: TextStyle(color: AppColors.textSecondary)),
              Text(Formatters.currency(9900),
                  style: const TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: const LinearProgressIndicator(
              value: 0.78,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBudgetCard extends StatelessWidget {
  final VoidCallback onSeeAll;

  const _CategoryBudgetCard({required this.onSeeAll});

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
                onTap: onSeeAll,
                child: const Row(
                  children: [
                    Text('Tümü',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < _categories.length; i++) ...[
            _CategoryRow(category: _categories[i]),
            if (i != _categories.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _BudgetCategory category;

  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category.icon, color: category.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    Text(
                      Formatters.currency(category.spent),
                      style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text('${Formatters.currency(category.budget)} bütçe',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ),
                    Text('%${category.usagePercent}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: category.usagePercent / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(category.color),
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
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  const _AnalyticsRow();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(child: _DistributionCard()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _SummaryCard()),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard();

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
                      for (final c in _categories)
                        PieChartSectionData(
                          value: c.sharePercent.toDouble(),
                          color: c.color,
                          title: '%${c.sharePercent}',
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
                    Text(Formatters.currency(45000).split(',').first,
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
          for (final c in _categories)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: c.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11)),
                  ),
                  Text('%${c.sharePercent}',
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
  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.account_balance_wallet_outlined, AppColors.primary, 'Toplam Bütçe',
          Formatters.currency(45000)),
      (Icons.trending_up, AppColors.success, 'Toplam Harcama',
          Formatters.currency(35100)),
      (Icons.pie_chart_outline, AppColors.warning, 'Kalan Bütçe',
          Formatters.currency(9900)),
      (Icons.percent, AppColors.accent, 'Kullanım Oranı', '%78'),
      (Icons.calendar_month_outlined, AppColors.accent, 'Dönem',
          '1 Mayıs - 31 Mayıs 2025'),
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
                                fontSize: 12, fontWeight: FontWeight.w700)),
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
  final ValueChanged<String> onAction;

  const _QuickActions({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add, AppColors.success, 'Kategori Ekle'),
      (Icons.edit_outlined, AppColors.warning, 'Bütçe Düzenle'),
      (Icons.copy_outlined, AppColors.primary, 'Geçen Aydan Kopyala'),
      (Icons.show_chart, AppColors.accent, 'Raporu Görüntüle'),
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
                    onTap: () => onAction(a.$3),
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
                          Text(
                            a.$3,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: a.$2,
                              height: 1.2,
                            ),
                          ),
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
