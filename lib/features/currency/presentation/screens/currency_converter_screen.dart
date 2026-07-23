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
import '../../data/exchange_rate_service.dart';
import '../providers/exchange_rate_providers.dart';

/// Para birimi: kod + ad + TRY karşısındaki orta kur (TRY/birim).
class _Cur {
  final String code;
  final String name;
  final double rate; // 1 birim = rate TRY
  const _Cur(this.code, this.name, this.rate);
}

/// Ekran — Döviz Çevirici (canlı TCMB kurlarıyla).
class CurrencyConverterScreen extends ConsumerStatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  ConsumerState<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState
    extends ConsumerState<CurrencyConverterScreen> {
  final _amountController = TextEditingController(text: '100');
  String _fromCode = 'USD';
  String _toCode = 'TRY';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<_Cur> _currencies(ExchangeData data) {
    return [
      const _Cur('TRY', 'Türk Lirası', 1),
      for (final r in data.rates)
        _Cur(r.code, r.name, (r.buy + r.sell) / 2),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(exchangeRatesProvider);

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
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: async.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(
                    child: Text('Kurlar yüklenemedi. İnterneti kontrol et.')),
                data: (data) => _buildContent(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Expanded(
            child: Center(
              child: Text('Döviz Çevirici',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent(ExchangeData data) {
    final currencies = _currencies(data);
    _Cur curOf(String code) =>
        currencies.firstWhere((c) => c.code == code, orElse: () => currencies.first);

    final from = curOf(_fromCode);
    final to = curOf(_toCode);
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ?? 0;
    final result = to.rate == 0 ? 0.0 : amount * from.rate / to.rate;
    final unitRate = to.rate == 0 ? 0.0 : from.rate / to.rate;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _converterCard(currencies, from, to, result),
          const SizedBox(height: AppSpacing.lg),
          _rateInfo(from, to, unitRate),
          const SizedBox(height: AppSpacing.lg),
          _quickAmounts(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Kaynak: TCMB • ${Formatters.longDate(data.updatedAt)}',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _converterCard(
      List<_Cur> currencies, _Cur from, _Cur to, double result) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            // Çevrilecek
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Çevrilecek Tutar',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _currencyButton(currencies, from.code,
                          (c) => setState(() => _fromCode = c)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          onChanged: (_) => setState(() {}),
                          textAlign: TextAlign.right,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
                          ],
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w800),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Sonuç
            AppCard(
              color: AppColors.primary.withValues(alpha: 0.06),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sonuç',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _currencyButton(currencies, to.code,
                          (c) => setState(() => _toCode = c)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            Formatters.amount(result),
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Takas butonu (ortada)
        Positioned(
          child: GestureDetector(
            onTap: () => setState(() {
              final tmp = _fromCode;
              _fromCode = _toCode;
              _toCode = tmp;
            }),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3),
              ),
              child: const Icon(Icons.swap_vert, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _currencyButton(
      List<_Cur> currencies, String code, ValueChanged<String> onSelect) {
    return GestureDetector(
      onTap: () => _pickCurrency(currencies, onSelect),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
              child: Text(code.substring(0, 2),
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(code,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Icon(Icons.keyboard_arrow_down,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCurrency(
      List<_Cur> currencies, ValueChanged<String> onSelect) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('Para Birimi Seç',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final c in currencies)
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                  child: Text(c.code.substring(0, 2),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
                title: Text(c.code),
                subtitle: Text(c.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.pop(context, c.code),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onSelect(selected);
  }

  Widget _rateInfo(_Cur from, _Cur to, double unitRate) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_alt, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '1 ${from.code} = ${Formatters.amount(unitRate)} ${to.code}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAmounts() {
    const amounts = [100, 500, 1000, 10000];
    return Row(
      children: [
        for (final a in amounts)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => setState(
                    () => _amountController.text = a.toString()),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(Formatters.amount(a.toDouble()).split(',').first,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
