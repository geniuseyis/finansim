import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_durations.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/extensions/category_ui.dart';
import '../../../transactions/presentation/providers/finance_summary_provider.dart';

/// Bir gider kategorisinin istatistik satırı.
class _CategoryStat {
  final String name;
  final double amount;
  final int percent;
  final IconData icon;
  final Color color;

  const _CategoryStat(
    this.name,
    this.amount,
    this.percent,
    this.icon,
    this.color,
  );
}

/// Ekran 10 — İstatistikler (gerçek işlem verisinden türetilir).
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _period = 2;
  int _distMode = 0;

  static String _rangeLabel(StatsPeriod period) {
    final now = DateTime.now();
    final w = period.window(now);
    return switch (period) {
      StatsPeriod.day => Formatters.longDate(now),
      StatsPeriod.week =>
        '${Formatters.shortDate(w.start)} – ${Formatters.shortDate(now)}',
      StatsPeriod.month => Formatters.longDate(
        now,
      ).split(' ').sublist(1).join(' '),
      StatsPeriod.year => '${now.year}',
    };
  }

  List<_CategoryStat> _categoryStats(FinanceSummary s) {
    final total = s.expense;
    final entries = s.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in entries)
        _CategoryStat(
          e.key.label,
          e.value,
          total > 0 ? (e.value / total * 100).round() : 0,
          e.key.icon,
          e.key.color,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(financeSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(currentIndex: -1),
      body: SafeArea(
        bottom: false,
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (all) {
            final period = StatsPeriod.values[_period];
            final s = FinanceSummary.forPeriod(all.all, period);
            final stats = _categoryStats(s);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _TopBar(),
                  const SizedBox(height: AppSpacing.md),
                  _FilterRow(
                    period: _period,
                    onPeriod: (p) => setState(() => _period = p),
                    rangeLabel: _rangeLabel(period),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SummaryCard(summary: s),
                  const SizedBox(height: AppSpacing.lg),
                  _DistributionCard(
                    stats: stats,
                    total: s.expense,
                    mode: _distMode,
                    onMode: (m) => setState(() => _distMode = m),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Trend her zaman son 7 günü gösterir (dönemden bağımsız).
                  _TrendCard(summary: all),
                  const SizedBox(height: AppSpacing.lg),
                  _CategoryAnalysisCard(
                    stats: stats,
                    onSeeAll: () => context.push(AppRoutes.categories),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppBackButton(),
        Expanded(
          child: Center(
            child: Text(
              'İstatistikler',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SizedBox.square(dimension: 44),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final int period;
  final ValueChanged<int> onPeriod;
  final String rangeLabel;

  const _FilterRow({
    required this.period,
    required this.onPeriod,
    required this.rangeLabel,
  });

  static const _labels = ['Gün', 'Hafta', 'Ay', 'Yıl'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                for (var i = 0; i < _labels.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: period == i,
                      child: GestureDetector(
                        onTap: () => onPeriod(i),
                        child: AnimatedContainer(
                          duration: AppDurations.fast,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: period == i
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            _labels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: period == i
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: Semantics(
            label: 'Dönem: $rangeLabel',
            excludeSemantics: true,
            child: Container(
              height: 48,
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
                  Expanded(
                    child: Text(
                      rangeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final FinanceSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _col(
              'Toplam Gelir',
              summary.income,
              summary.incomeChange,
              AppColors.success,
            ),
            _divider(),
            _col(
              'Toplam Gider',
              summary.expense,
              summary.expenseChange,
              AppColors.error,
            ),
            _divider(),
            _col(
              'Net Tasarruf',
              summary.net,
              summary.netChange,
              AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.lg);

  Widget _col(String title, double amount, double percent, Color color) {
    final up = percent >= 0;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.currency(amount),
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                up ? Icons.arrow_upward : Icons.arrow_downward,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 2),
              Text(
                Formatters.percent(percent),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  final List<_CategoryStat> stats;
  final double total;
  final int mode;
  final ValueChanged<int> onMode;

  const _DistributionCard({
    required this.stats,
    required this.total,
    required this.mode,
    required this.onMode,
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
                child: Text(
                  'Harcama Dağılımı',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              _miniToggle(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (stats.isEmpty)
            const _EmptyHint('Henüz gider verisi yok.')
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 45,
                          sections: [
                            for (final c in stats)
                              PieChartSectionData(
                                value: c.amount,
                                color: c.color,
                                title: '%${c.percent}',
                                radius: 26,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
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
                            'Toplam Gider',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            Formatters.currency(total).split(',').first,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    children: [for (final c in stats) _legendRow(c)],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _miniToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [_miniTab('Dağılım', 0), _miniTab('Karşılaştırma', 1)],
      ),
    );
  }

  Widget _miniTab(String label, int value) {
    final active = mode == value;
    return GestureDetector(
      onTap: () => onMode(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _legendRow(_CategoryStat c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(c.icon, size: 16, color: c.color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              c.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            Formatters.currency(c.amount).split(',').first,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 30,
            child: Text(
              '%${c.percent}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final FinanceSummary summary;
  const _TrendCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final income = summary.dailyTrend(7, type: TransactionType.income);
    final expense = summary.dailyTrend(7, type: TransactionType.expense);
    final labels = [for (final p in income) p.label];
    final maxVal = [
      ...income.map((e) => e.value),
      ...expense.map((e) => e.value),
    ].fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = _niceMax(maxVal);
    final interval = maxY / 4;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Harcama Trendi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  'Son 7 Gün',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: _chart(income, expense, labels, maxY, interval),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.primary, 'Gelir'),
              const SizedBox(width: AppSpacing.lg),
              _legendDot(AppColors.error, 'Gider'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  LineChartBarData _bar(List<DayPoint> values, Color color) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < values.length; i++)
          FlSpot(i.toDouble(), values[i].value),
      ],
      isCurved: true,
      preventCurveOverShooting: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (s, p, b, i) => FlDotCirclePainter(
          radius: 3.5,
          color: Colors.white,
          strokeWidth: 2,
          strokeColor: color,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  Widget _chart(
    List<DayPoint> income,
    List<DayPoint> expense,
    List<String> labels,
    double maxY,
    double interval,
  ) {
    return LineChart(
      duration: AppDurations.slow,
      LineChartData(
        minX: 0,
        maxX: (labels.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 38,
              getTitlesWidget: (v, _) => Text(
                _compact(v),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 22,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              final isIncome = s.barIndex == 0;
              return LineTooltipItem(
                '${isIncome ? 'Gelir' : 'Gider'}: '
                '${Formatters.currency(s.y).split(',').first}',
                TextStyle(
                  color: isIncome ? AppColors.primary : AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          _bar(income, AppColors.primary),
          _bar(expense, AppColors.error),
        ],
      ),
    );
  }
}

class _CategoryAnalysisCard extends StatelessWidget {
  final List<_CategoryStat> stats;
  final VoidCallback onSeeAll;

  const _CategoryAnalysisCard({required this.stats, required this.onSeeAll});

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
                child: Text(
                  'Kategori Analizi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Row(
                  children: [
                    Text(
                      'Tümünü Gör',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (stats.isEmpty)
            const _EmptyHint(
              'Gider eklediğinde kategori analizi burada görünür.',
            )
          else
            for (var i = 0; i < stats.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _item(stats[i])),
                    const SizedBox(width: AppSpacing.md),
                    if (i + 1 < stats.length)
                      Expanded(child: _item(stats[i + 1]))
                    else
                      const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _item(_CategoryStat c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(c.icon, size: 20, color: c.color),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '%${c.percent}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: c.percent / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(c.color),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                Formatters.currency(c.amount),
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

/// Veriye göre "güzel" bir tavan değeri hesaplar.
double _niceMax(double v) {
  if (v <= 0) return 1000;
  final exponent = (math.log(v) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  final normalized = v / magnitude;
  final niceNormalized = normalized <= 1
      ? 1.0
      : normalized <= 2
      ? 2.0
      : normalized <= 5
      ? 5.0
      : 10.0;
  return niceNormalized * magnitude;
}

String _compact(double v) {
  if (v >= 1000) {
    final k = v / 1000;
    return '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}K';
  }
  return v.toInt().toString();
}
