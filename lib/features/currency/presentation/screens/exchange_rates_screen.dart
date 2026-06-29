import 'package:flutter/material.dart';
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

const _popularCodes = ['USD', 'EUR', 'GBP', 'CHF', 'JPY', 'SAR'];

enum _Filter { all, popular, gainers, losers, watchlist }

/// Ekran 19 — Döviz Kurları. Veriler canlı olarak TCMB'den alınır.
class ExchangeRatesScreen extends ConsumerStatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  ConsumerState<ExchangeRatesScreen> createState() =>
      _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends ConsumerState<ExchangeRatesScreen> {
  final _searchController = TextEditingController();
  final Set<String> _favorites = {};
  _Filter _filter = _Filter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
      );

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
          } else {
            _soon();
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(
            onRetry: () => ref.invalidate(exchangeRatesProvider),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(exchangeRatesProvider);
              await ref.read(exchangeRatesProvider.future);
            },
            child: _buildContent(data),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ExchangeData data) {
    final all = data.rates;
    final query = _query.toLowerCase();

    List<CurrencyRate> applyQuery(List<CurrencyRate> list) => query.isEmpty
        ? list
        : list
            .where((r) =>
                r.code.toLowerCase().contains(query) ||
                r.name.toLowerCase().contains(query))
            .toList();

    final popular = [
      for (final code in _popularCodes)
        if (data.byCode(code) != null) data.byCode(code)!,
    ];
    final others =
        all.where((r) => !_popularCodes.contains(r.code)).toList();

    final filteredSingle = switch (_filter) {
      _Filter.popular => popular,
      _Filter.gainers =>
        all.where((r) => r.changePercent > 0).toList(),
      _Filter.losers => all.where((r) => r.changePercent < 0).toList(),
      _Filter.watchlist =>
        all.where((r) => _favorites.contains(r.code)).toList(),
      _Filter.all => <CurrencyRate>[],
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        120,
      ),
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
        _SummaryCard(data: data),
        const SizedBox(height: AppSpacing.lg),
        if (_filter == _Filter.all && query.isEmpty) ...[
          _tableCard('Popüler Döviz Kurları', popular, seeAll: true),
          const SizedBox(height: AppSpacing.lg),
          _tableCard('Diğer Döviz Kurları', others),
        ] else
          _tableCard(
            _filterTitle(),
            applyQuery(_filter == _Filter.all ? all : filteredSingle),
          ),
        const SizedBox(height: AppSpacing.lg),
        _ConverterCard(onTap: () => context.push(AppRoutes.converter)),
        const SizedBox(height: AppSpacing.md),
        _Footer(updatedAt: data.updatedAt),
      ],
    );
  }

  String _filterTitle() => switch (_filter) {
        _Filter.popular => 'Popüler Döviz Kurları',
        _Filter.gainers => 'Yükselenler',
        _Filter.losers => 'Düşenler',
        _Filter.watchlist => 'Takip Ettiklerim',
        _Filter.all => 'Arama Sonuçları',
      };

  Widget _tableCard(String title, List<CurrencyRate> rates,
      {bool seeAll = false}) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              if (seeAll)
                GestureDetector(
                  onTap: _soon,
                  child: const Row(
                    children: [
                      Text('Tümünü Gör',
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
          if (rates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text('Sonuç yok.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            for (var i = 0; i < rates.length; i++) ...[
              _RateRow(
                rate: rates[i],
                favorite: _favorites.contains(rates[i].code),
                onFavorite: () => setState(() {
                  if (!_favorites.add(rates[i].code)) {
                    _favorites.remove(rates[i].code);
                  }
                }),
              ),
              if (i != rates.length - 1) const Divider(height: 1),
            ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Döviz Kurları',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Güncel döviz kurlarını takip edin',
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
              hintText: 'Döviz ara...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              fillColor: AppColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
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
              borderRadius: BorderRadius.circular(AppRadius.lg),
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
  final _Filter filter;
  final ValueChanged<_Filter> onChanged;

  const _FilterTabs({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (_Filter.all, Icons.grid_view_rounded, 'Tümü', AppColors.primary),
      (_Filter.popular, Icons.star_outline, 'Popüler', AppColors.warning),
      (_Filter.gainers, Icons.trending_up, 'Yükselenler', AppColors.success),
      (_Filter.losers, Icons.trending_down, 'Düşenler', AppColors.error),
      (_Filter.watchlist, Icons.bookmark_outline, 'Takip Ettiklerim',
          AppColors.accent),
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in tabs)
              GestureDetector(
                onTap: () => onChanged(t.$1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: filter == t.$1
                        ? t.$4.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(t.$2,
                          size: 16,
                          color: filter == t.$1
                              ? t.$4
                              : AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(t.$3,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: filter == t.$1
                                  ? t.$4
                                  : AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ExchangeData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final rates = data.rates;
    final avg = rates.isEmpty
        ? 0.0
        : rates.map((r) => r.changePercent).reduce((a, b) => a + b) /
            rates.length;
    final gainer = rates.isEmpty
        ? null
        : rates.reduce((a, b) => a.changePercent >= b.changePercent ? a : b);
    final loser = rates.isEmpty
        ? null
        : rates.reduce((a, b) => a.changePercent <= b.changePercent ? a : b);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _col(Icons.show_chart, AppColors.primary, 'Ortalama Değişim',
                Formatters.percent(avg), avg >= 0, sub: 'Tüm Pariteler'),
            _divider(),
            _col(Icons.arrow_upward, AppColors.success, 'En Yüksek',
                gainer?.pair ?? '-', true,
                sub: gainer != null ? Formatters.percent(gainer.changePercent) : ''),
            _divider(),
            _col(Icons.arrow_downward, AppColors.error, 'En Düşük',
                loser?.pair ?? '-', false,
                sub: loser != null ? Formatters.percent(loser.changePercent) : ''),
            _divider(),
            _col(Icons.access_time, AppColors.accent, 'Son Güncelleme',
                Formatters.time(data.updatedAt), true,
                plain: true, sub: Formatters.longDate(data.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.md);

  Widget _col(IconData icon, Color color, String title, String value, bool up,
      {String sub = '', bool plain = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: plain ? AppColors.textPrimary : color)),
          ),
          if (sub.isNotEmpty)
            Text(sub,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 9,
                    color: plain ? AppColors.textSecondary : color)),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final CurrencyRate rate;
  final bool favorite;
  final VoidCallback onFavorite;

  const _RateRow({
    required this.rate,
    required this.favorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final up = rate.changePercent >= 0;
    final color = up ? AppColors.success : AppColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            child: Text(rate.code.substring(0, 2),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rate.pair,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(rate.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.currency(rate.sell),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12)),
              Text(Formatters.currency(rate.buy),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 36,
            height: 22,
            child: CustomPaint(painter: _SparkPainter(rate.spark, color)),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '${Formatters.percent(rate.changePercent)} ${up ? '↑' : '↓'}',
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
          GestureDetector(
            onTap: onFavorite,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                favorite ? Icons.star : Icons.star_outline,
                size: 18,
                color: favorite ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SparkPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-9 ? 1 : (maxV - minV);
    final dx = size.width / (points.length - 1);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = dx * i;
      final y = size.height - ((points[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.points != points || old.color != color;
}

class _ConverterCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ConverterCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.currency_exchange,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Döviz Çevirici',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                const Text(
                    'Hızlı ve kolay döviz çevirisi yapmak için çevirici aracımızı kullanın.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3)),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Çeviriciye Git',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right,
                            color: Colors.white, size: 18),
                      ],
                    ),
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

class _Footer extends StatelessWidget {
  final DateTime updatedAt;

  const _Footer({required this.updatedAt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Kurlar ${Formatters.longDate(updatedAt)}, '
            '${Formatters.time(updatedAt)} itibarıyla güncellenmiştir.',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        const Text('Kaynak: TCMB',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            const Text('Kurlar yüklenemedi',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: AppSpacing.xs),
            const Text('İnternet bağlantını kontrol edip tekrar dene.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
          ],
        ),
      ),
    );
  }
}
