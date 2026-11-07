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
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../../transactions/presentation/providers/finance_summary_provider.dart';

const Color _pink = Color(0xFFEC4899);

/// Kategori görseli: ikon + renk + alt açıklama.
(IconData, Color, String) _visual(TransactionCategory c) => switch (c) {
      TransactionCategory.general =>
        (Icons.category_outlined, AppColors.primary, 'Genel işlemler'),
      TransactionCategory.salary => (
          Icons.account_balance_wallet_outlined,
          AppColors.success,
          'Maaş gelirleri'
        ),
      TransactionCategory.investment =>
        (Icons.show_chart, AppColors.accent, 'Yatırım gelirleri'),
      TransactionCategory.freelance =>
        (Icons.work_outline, AppColors.success, 'Serbest çalışma'),
      TransactionCategory.sales =>
        (Icons.sell_outlined, AppColors.success, 'Satış gelirleri'),
      TransactionCategory.food =>
        (Icons.restaurant_outlined, AppColors.warning, 'Yemek & restoran'),
      TransactionCategory.transport =>
        (Icons.directions_bus_outlined, AppColors.primary, 'Ulaşım & yakıt'),
      TransactionCategory.bills =>
        (Icons.receipt_long_outlined, AppColors.accent, 'Faturalar'),
      TransactionCategory.shopping =>
        (Icons.shopping_bag_outlined, _pink, 'Alışveriş'),
      TransactionCategory.health =>
        (Icons.favorite_outline, AppColors.error, 'Sağlık'),
      TransactionCategory.entertainment =>
        (Icons.local_activity_outlined, _pink, 'Eğlence'),
      TransactionCategory.education =>
        (Icons.school_outlined, AppColors.warning, 'Eğitim'),
      TransactionCategory.other =>
        (Icons.more_horiz, AppColors.textSecondary, 'Diğer'),
    };

/// Bir kategoriye ait, işlemlerden hesaplanmış istatistik.
class _CatStat {
  final TransactionCategory category;
  final int count;
  final double income;
  final double expense;

  const _CatStat(this.category, this.count, this.income, this.expense);

  double get total => income + expense;
  bool get isIncome => income >= expense;
  double get amount => total;
}

List<_CatStat> _computeStats(List<AppTransaction> txns) {
  final byCat = <TransactionCategory, List<AppTransaction>>{};
  for (final t in txns) {
    (byCat[t.category] ??= []).add(t);
  }
  final stats = <_CatStat>[];
  byCat.forEach((cat, list) {
    var income = 0.0;
    var expense = 0.0;
    for (final t in list) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    stats.add(_CatStat(cat, list.length, income, expense));
  });
  stats.sort((a, b) => b.total.compareTo(a.total));
  return stats;
}

/// Ekran 15 — Kategoriler (gerçek veri; işlemlerden hesaplanır).
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();
  int _filter = 0; // 0 Tümü, 1 Gider, 2 Gelir, 3 Özel
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _customInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Kategoriler işlemlerinizden otomatik oluşur; işlem eklerken kategori seçebilirsiniz.'),
      ),
    );
  }

  List<_CatStat> _applyFilters(List<_CatStat> stats) {
    return stats.where((s) {
      final byTab = switch (_filter) {
        1 => !s.isIncome,
        2 => s.isIncome,
        3 => false, // Özel kategori (enum modelinde yok)
        _ => true,
      };
      final byQuery = _query.isEmpty ||
          s.category.label.toLowerCase().contains(_query.toLowerCase());
      return byTab && byQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(financeSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
      ),
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (summary) => _buildContent(_computeStats(summary.all)),
        ),
      ),
    );
  }

  Widget _buildContent(List<_CatStat> stats) {
    final filtered = _applyFilters(stats);
    final totalExpense =
        stats.fold<double>(0, (s, c) => s + c.expense);
    final popular = stats.where((s) => s.expense > 0).toList()
      ..sort((a, b) => b.expense.compareTo(a.expense));
    final giderCount = stats.where((s) => !s.isIncome).length;
    final gelirCount = stats.where((s) => s.isIncome).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(onBell: () => context.push(AppRoutes.notifications)),
          const SizedBox(height: AppSpacing.lg),
          _SearchRow(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            onFilter: _customInfo,
          ),
          const SizedBox(height: AppSpacing.md),
          _FilterTabs(
            filter: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryCard(
            total: stats.length,
            gider: giderCount,
            gelir: gelirCount,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (stats.isEmpty)
            const _EmptyState()
          else ...[
            if (popular.isNotEmpty) ...[
              const Text('Popüler Kategoriler',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              _PopularList(items: popular.take(5).toList(), total: totalExpense),
              const SizedBox(height: AppSpacing.lg),
            ],
            const Text('Tüm Kategoriler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            _AllCategoriesCard(items: filtered),
            const SizedBox(height: AppSpacing.lg),
          ],
          _AddCategoryButton(onTap: _customInfo),
        ],
      ),
    );
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
        const AppBackButton(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategoriler',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Gelir & gider kategorilerini yönet',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
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
                      border: Border.all(color: AppColors.background, width: 2),
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
              hintText: 'Kategori ara...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              fillColor: AppColors.surface,
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
                Text('Filtrele',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final int filter;
  final ValueChanged<int> onChanged;

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
          _tab(0, Icons.grid_view_rounded, 'Tümü', AppColors.primary),
          _tab(1, Icons.south_east, 'Gider', AppColors.error),
          _tab(2, Icons.north_east, 'Gelir', AppColors.success),
          _tab(3, Icons.star_outline, 'Özel', AppColors.accent),
        ],
      ),
    );
  }

  Widget _tab(int value, IconData icon, String label, Color color) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16, color: active ? color : AppColors.textSecondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? color : AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final int gider;
  final int gelir;

  const _SummaryCard(
      {required this.total, required this.gider, required this.gelir});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _col(Icons.grid_view_rounded, AppColors.primary, 'Toplam Kategori',
                '$total'),
            _divider(),
            _col(Icons.south_east, AppColors.error, 'Gider Kategori', '$gider'),
            _divider(),
            _col(Icons.north_east, AppColors.success, 'Gelir Kategori',
                '$gelir'),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.md);

  Widget _col(IconData icon, Color color, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _PopularList extends StatelessWidget {
  final List<_CatStat> items;
  final double total;

  const _PopularList({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final s = items[index];
          final (icon, color, _) = _visual(s.category);
          final percent =
              total <= 0 ? 0 : (s.expense / total * 100).round();
          return AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: 92,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(s.category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(Formatters.currency(s.expense),
                        style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                  Text('%$percent',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AllCategoriesCard extends StatelessWidget {
  final List<_CatStat> items;

  const _AllCategoriesCard({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text('Bu filtrede kategori yok.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _CategoryRow(stat: items[i]),
            if (i != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _CatStat stat;

  const _CategoryRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    final (icon, color, subtitle) = _visual(stat.category);
    final isIncome = stat.isIncome;
    final amountColor = isIncome ? AppColors.success : AppColors.error;

    return Padding(
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
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(isIncome ? 'Gelir' : 'Gider',
                style: TextStyle(
                    color: amountColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${stat.count} işlem',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(Formatters.currency(stat.amount),
                  style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
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
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.grid_view_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Henüz kategori verisi yok',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'İşlem ekledikçe kategoriler burada gerçek tutar ve sayılarla görünür.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCategoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primary),
            SizedBox(width: AppSpacing.xs),
            Text('Yeni Kategori Ekle',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
