import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';

const Color _pink = Color(0xFFEC4899);

enum _CatType { gider, gelir }

/// Tüm kategoriler listesindeki bir kategori (dummy veri).
class _Category {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final _CatType type;
  final int count;
  final double amount;

  const _Category(this.name, this.subtitle, this.icon, this.color, this.type,
      this.count, this.amount);
}

final _categories = <_Category>[
  _Category('Market & Alışveriş', 'Market alışverişleri',
      Icons.shopping_bag_outlined, AppColors.success, _CatType.gider, 45, 13450),
  _Category('Yemek & Restoran', 'Yemek ve restoran harcamaları',
      Icons.restaurant_outlined, AppColors.warning, _CatType.gider, 38, 10120),
  _Category('Ulaşım', 'Toplu taşıma ve yakıt', Icons.directions_bus_outlined,
      AppColors.primary, _CatType.gider, 28, 7590),
  _Category('Faturalar', 'Elektrik, su, internet vb.', Icons.home_outlined,
      AppColors.accent, _CatType.gider, 16, 5060),
  _Category('Eğlence', 'Sinema, konser, oyun vb.', Icons.local_activity_outlined,
      _pink, _CatType.gider, 12, 3370),
  _Category('Diğer', 'Diğer harcamalar', Icons.more_horiz,
      AppColors.textSecondary, _CatType.gider, 20, 2560),
  _Category('Maaş', 'Aylık maaş gelirleri', Icons.account_balance_wallet_outlined,
      AppColors.success, _CatType.gelir, 3, 28750),
  _Category('Freelance Gelir', 'Freelance ve serbest çalışma',
      Icons.work_outline, AppColors.success, _CatType.gelir, 7, 15200),
  _Category('Yatırım Geliri', 'Yatırım ve faiz gelirleri',
      Icons.card_giftcard, AppColors.warning, _CatType.gelir, 5, 8500),
  _Category('Diğer Gelir', 'Diğer gelir kaynakları', Icons.show_chart,
      AppColors.primary, _CatType.gelir, 4, 2000),
];

class _Popular {
  final String name;
  final IconData icon;
  final Color color;
  final double amount;
  final int percent;

  const _Popular(this.name, this.icon, this.color, this.amount, this.percent);
}

const _popular = <_Popular>[
  _Popular('Market', Icons.shopping_cart_outlined, AppColors.success, 13450, 32),
  _Popular('Yemek', Icons.restaurant_outlined, AppColors.warning, 10120, 24),
  _Popular('Ulaşım', Icons.directions_bus_outlined, AppColors.primary, 7590, 18),
  _Popular('Faturalar', Icons.home_outlined, AppColors.accent, 5060, 12),
  _Popular('Eğlence', Icons.local_activity_outlined, _pink, 3370, 8),
];

/// Ekran 15 — Kategoriler (tasarım birebir, dummy veri).
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();
  int _filter = 0; // 0 Tümü, 1 Gider, 2 Gelir, 3 Özel
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _soon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
  }

  List<_Category> get _filtered {
    return _categories.where((c) {
      final byTab = switch (_filter) {
        1 => c.type == _CatType.gider,
        2 => c.type == _CatType.gelir,
        3 => false, // Özel kategori (dummy'de yok)
        _ => true,
      };
      final byQuery = _query.isEmpty ||
          c.name.toLowerCase().contains(_query.toLowerCase());
      return byTab && byQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
        onAdd: () => context.push(AppRoutes.addTransaction),
        onTap: (i) {
          if (i == 0) {
            context.go(AppRoutes.dashboard);
          } else if (i == 1) {
            context.go(AppRoutes.transactions);
          } else if (i == 3) {
            context.push(AppRoutes.budget);
          } else if (i == 4) {
            context.push(AppRoutes.profile);
          } else {
            _soon();
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onBell: () => context.push(AppRoutes.notifications)),
              const SizedBox(height: AppSpacing.lg),
              _SearchRow(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                onFilter: _soon,
              ),
              const SizedBox(height: AppSpacing.md),
              _FilterTabs(
                filter: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: AppSpacing.md),
              const _SummaryCard(),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('Popüler Kategoriler', onAction: _soon),
              const SizedBox(height: AppSpacing.sm),
              const _PopularList(),
              const SizedBox(height: AppSpacing.lg),
              const Text('Tüm Kategoriler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              _AllCategoriesCard(items: _filtered, onMenu: _soon),
              const SizedBox(height: AppSpacing.lg),
              _AddCategoryButton(onTap: _soon),
            ],
          ),
        ),
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
                      border:
                          Border.all(color: AppColors.background, width: 2),
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
              prefixIcon:
                  Icon(Icons.search, color: AppColors.textSecondary),
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
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _col(Icons.grid_view_rounded, AppColors.primary, 'Toplam Kategori',
                '18'),
            _divider(),
            _col(Icons.south_east, AppColors.error, 'Gider Kategori', '12'),
            _divider(),
            _col(Icons.north_east, AppColors.success, 'Gelir Kategori', '4'),
            _divider(),
            _col(Icons.star, AppColors.accent, 'Özel Kategori', '2'),
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
              style: TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onAction;

  const _SectionTitle(this.title, {required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        GestureDetector(
          onTap: onAction,
          child: const Row(
            children: [
              Text('Tümünü Gör',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}

class _PopularList extends StatelessWidget {
  const _PopularList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _popular.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final p = _popular[index];
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
                      color: p.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(p.icon, color: p.color),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(Formatters.currency(p.amount),
                        style: TextStyle(
                            color: p.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                  Text('%${p.percent}',
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
  final List<_Category> items;
  final VoidCallback onMenu;

  const _AllCategoriesCard({required this.items, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        padding: EdgeInsets.all(AppSpacing.xl),
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
            _CategoryRow(category: items[i], onMenu: onMenu),
            if (i != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _Category category;
  final VoidCallback onMenu;

  const _CategoryRow({required this.category, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    final isIncome = category.type == _CatType.gelir;
    final amountColor = isIncome ? AppColors.success : AppColors.error;
    final badgeColor = isIncome ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(category.subtitle,
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
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(isIncome ? 'Gelir' : 'Gider',
                style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${category.count} işlem',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(Formatters.currency(category.amount),
                  style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          IconButton(
            onPressed: onMenu,
            icon: Icon(Icons.more_vert,
                size: 18, color: AppColors.textSecondary),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
