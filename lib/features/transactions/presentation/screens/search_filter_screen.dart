import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_filter.dart';
import '../providers/transaction_filter_provider.dart';
import '../providers/transaction_providers.dart';

const Color _pink = Color(0xFFEC4899);

/// _categoryOptions ile aynı sıradaki gerçek kategori eşlemesi.
const _categoryEnums = <TransactionCategory>[
  TransactionCategory.shopping,
  TransactionCategory.food,
  TransactionCategory.transport,
  TransactionCategory.bills,
  TransactionCategory.entertainment,
  TransactionCategory.other,
  TransactionCategory.salary,
  TransactionCategory.freelance,
  TransactionCategory.investment,
  TransactionCategory.general,
];

class _Option {
  final String label;
  final IconData icon;
  final Color color;
  const _Option(this.label, this.icon, this.color);
}

const _dateOptions = <_Option>[
  _Option('Tümü', Icons.calendar_today_outlined, AppColors.primary),
  _Option('Bugün', Icons.calendar_today_outlined, AppColors.success),
  _Option('Dün', Icons.calendar_today_outlined, AppColors.warning),
  _Option('Bu Hafta', Icons.calendar_today_outlined, AppColors.accent),
  _Option('Bu Ay', Icons.calendar_today_outlined, AppColors.primary),
  _Option('Geçen Ay', Icons.calendar_today_outlined, AppColors.error),
  _Option('Son 3 Ay', Icons.calendar_today_outlined, AppColors.success),
];

const _typeOptions = <_Option>[
  _Option('Tümü', Icons.grid_view_rounded, AppColors.primary),
  _Option('Gelir', Icons.north_east, AppColors.success),
  _Option('Gider', Icons.south_east, AppColors.error),
];

final _categoryOptions = <_Option>[
  _Option('Market & Alışveriş', Icons.shopping_bag_outlined, AppColors.success),
  _Option('Yemek & Restoran', Icons.restaurant_outlined, AppColors.warning),
  _Option('Ulaşım', Icons.directions_bus_outlined, AppColors.primary),
  _Option('Faturalar', Icons.home_outlined, AppColors.accent),
  _Option('Eğlence', Icons.local_activity_outlined, _pink),
  _Option('Diğer', Icons.more_horiz, AppColors.textSecondary),
  _Option('Maaş', Icons.account_balance_wallet_outlined, AppColors.success),
  _Option('Freelance', Icons.work_outline, AppColors.success),
  _Option('Yatırım', Icons.card_giftcard, AppColors.warning),
  _Option('Diğer Gelir', Icons.show_chart, AppColors.primary),
];

/// İşlem ekleme ekranındaki ödeme yöntemleriyle aynı liste (ilk öğe: hepsi).
const _paymentOptions = <_Option>[
  _Option('Tümü', Icons.apps, AppColors.primary),
  _Option('Banka Hesabı', Icons.account_balance_outlined, AppColors.accent),
  _Option('Kredi Kartı', Icons.credit_card, AppColors.primary),
  _Option('Nakit', Icons.payments_outlined, AppColors.warning),
  _Option('Diğer', Icons.wallet_outlined, AppColors.success),
];

/// Ekran 16-17 — Arama & Filtre. Tam ekran filtre paneli.
class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final _searchController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  int _date = 0;
  int _type = 0;
  Set<int> _categories = {};
  int _payment = 0;

  @override
  void initState() {
    super.initState();
    // Aktif filtreyi ekrana önceden yükle.
    final f = ref.read(transactionFilterProvider);
    _searchController.text = f.query;
    _type = f.type == TransactionType.income
        ? 1
        : f.type == TransactionType.expense
            ? 2
            : 0;
    _date = f.date.index;
    _categories = f.categories
        .map(_categoryEnums.indexOf)
        .where((i) => i >= 0)
        .toSet();
    if (f.min != null) _minController.text = f.min!.toStringAsFixed(0);
    if (f.max != null) _maxController.text = f.max!.toStringAsFixed(0);
    _payment = f.paymentMethod == null
        ? 0
        : _paymentOptions.indexWhere((o) => o.label == f.paymentMethod)
            .clamp(0, _paymentOptions.length - 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _searchController.clear();
      _minController.clear();
      _maxController.clear();
      _date = 0;
      _type = 0;
      _categories = {};
      _payment = 0;
    });
  }

  double? _parseAmount(TextEditingController c) => double.tryParse(
      c.text.trim().replaceAll('.', '').replaceAll(',', '.'));

  TransactionFilter _currentFilter() {
    return TransactionFilter(
      query: _searchController.text.trim(),
      type: _type == 1
          ? TransactionType.income
          : _type == 2
              ? TransactionType.expense
              : null,
      categories: _categories.map((i) => _categoryEnums[i]).toSet(),
      date: _date >= 0 && _date < DatePreset.values.length
          ? DatePreset.values[_date]
          : DatePreset.all,
      min: _parseAmount(_minController),
      max: _parseAmount(_maxController),
      paymentMethod: _payment == 0 ? null : _paymentOptions[_payment].label,
    );
  }

  void _apply() {
    ref.read(transactionFilterProvider.notifier).set(_currentFilter());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _currentFilter();
    final resultCount = ref
            .watch(transactionsStreamProvider)
            .value
            ?.where(filter.matches)
            .length ??
        0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchField(),
                    const SizedBox(height: AppSpacing.xl),
                    _sectionTitle('Tarih Aralığı'),
                    const SizedBox(height: AppSpacing.sm),
                    _dateGrid(),
                    const SizedBox(height: AppSpacing.xl),
                    _sectionTitle('İşlem Türü'),
                    const SizedBox(height: AppSpacing.sm),
                    _typeRow(),
                    const SizedBox(height: AppSpacing.xl),
                    _sectionTitleWithAll('Kategori'),
                    const SizedBox(height: AppSpacing.sm),
                    _categoryGrid(),
                    const SizedBox(height: AppSpacing.xl),
                    _sectionTitle('Tutar Aralığı'),
                    const SizedBox(height: AppSpacing.sm),
                    _amountRow(),
                    const SizedBox(height: AppSpacing.xl),
                    _sectionTitleWithAll('Ödeme Yöntemi'),
                    const SizedBox(height: AppSpacing.sm),
                    _pillRow(_paymentOptions, _payment,
                        (i) => setState(() => _payment = i)),
                  ],
                ),
              ),
            ),
            _bottomBar(resultCount),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.close, size: 26),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Arama & Filtre',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('İşlemlerini kolayca bul',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _clear,
                child: const Text('Temizle',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'İşlem ara...',
          prefixIcon:
              Icon(Icons.search, color: AppColors.textSecondary),
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));

  Widget _sectionTitleWithAll(String title) => Row(
        children: [
          Expanded(child: _sectionTitle(title)),
          const Row(
            children: [
              Text('Tümü',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
            ],
          ),
        ],
      );

  Widget _dateGrid() {
    return Column(
      children: [
        for (var row = 0; row < 2; row++)
          Padding(
            padding: EdgeInsets.only(bottom: row == 0 ? AppSpacing.sm : 0),
            child: Row(
              children: [
                for (var col = 0; col < 4; col++) ...[
                  Expanded(child: _dateCard(row * 4 + col)),
                  if (col != 3) const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _dateCard(int index) {
    final o = _dateOptions[index];
    final selected = _date == index;
    return GestureDetector(
      onTap: () => setState(() => _date = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 80,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(o.icon, color: o.color, size: 22),
            const SizedBox(height: AppSpacing.xs),
            Text(o.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _typeRow() {
    return Row(
      children: [
        for (var i = 0; i < _typeOptions.length; i++) ...[
          Expanded(
            child: _segmentCard(
              _typeOptions[i],
              _type == i,
              () => setState(() => _type = i),
            ),
          ),
          if (i != _typeOptions.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _segmentCard(_Option o, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(o.icon, color: o.color, size: 18),
            const SizedBox(height: 2),
            Text(o.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _categoryGrid() {
    return Column(
      children: [
        for (var row = 0; row < 2; row++)
          Padding(
            padding: EdgeInsets.only(bottom: row == 0 ? AppSpacing.sm : 0),
            child: Row(
              children: [
                for (var col = 0; col < 5; col++) ...[
                  Expanded(child: _categoryCard(row * 5 + col)),
                  if (col != 4) const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _categoryCard(int index) {
    final o = _categoryOptions[index];
    final selected = _categories.contains(index);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _categories.remove(index);
        } else {
          _categories.add(index);
        }
      }),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 84,
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(o.icon, color: o.color, size: 22),
                const SizedBox(height: AppSpacing.xs),
                Text(o.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, height: 1.1)),
              ],
            ),
          ),
          if (selected)
            const Positioned(
              top: -4,
              right: -4,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _amountRow() {
    return Row(
      children: [
        Expanded(child: _amountField(_minController, 'Min. Tutar', '₺0,00')),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('-', style: TextStyle(color: AppColors.textSecondary)),
        ),
        Expanded(child: _amountField(_maxController, 'Max. Tutar', 'Sınırsız')),
      ],
    );
  }

  Widget _amountField(
      TextEditingController controller, String label, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 18, color: AppColors.success.withValues(alpha: 0.7)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                labelText: label,
                hintText: hint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillRow(
      List<_Option> options, int selected, ValueChanged<int> onTap) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            _pill(options[i], selected == i, i == 0, () => onTap(i)),
            if (i != options.length - 1) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  Widget _pill(_Option o, bool selected, bool first, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (!first) ...[
              Icon(o.icon, size: 16, color: o.color),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(o.label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('İptal'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.filter_alt_outlined, size: 18),
              label: Text('Filtrele ($count Sonuç)'),
            ),
          ),
        ],
      ),
    );
  }
}
