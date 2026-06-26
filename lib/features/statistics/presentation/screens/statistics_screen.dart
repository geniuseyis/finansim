import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_durations.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';

/// Bir gider kategorisinin istatistik verisi.
class _CategoryStat {
  final String name;
  final double amount;
  final int percent;
  final IconData icon;
  final Color color;

  const _CategoryStat(this.name, this.amount, this.percent, this.icon,
      this.color);
}

const _categoryStats = <_CategoryStat>[
  _CategoryStat('Market Alışverişi', 13450, 32, Icons.shopping_bag_outlined,
      AppColors.primary),
  _CategoryStat('Yemek & Restoran', 10120, 24, Icons.restaurant_outlined,
      AppColors.success),
  _CategoryStat('Ulaşım', 7590, 18, Icons.directions_car_outlined,
      AppColors.warning),
  _CategoryStat('Faturalar', 5060, 12, Icons.home_outlined, AppColors.accent),
  _CategoryStat('Eğlence', 3370, 8, Icons.local_activity_outlined,
      AppColors.error),
  _CategoryStat('Diğer', 2560, 6, Icons.more_horiz, AppColors.textSecondary),
];

/// Ekran 10 — İstatistikler.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _period = 2; // Gün, Hafta, Ay(2), Yıl
  int _distMode = 0; // Dağılım(0), Karşılaştırma(1)

  void _soon() {
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
        currentIndex: -1,
        onAdd: () => context.push(AppRoutes.addTransaction),
        onTap: (i) {
          if (i == 0) {
            context.go(AppRoutes.dashboard);
          } else if (i == 1) {
            context.go(AppRoutes.transactions);
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
            AppSpacing.xs,
            AppSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(onCalendar: _soon),
              const SizedBox(height: AppSpacing.md),
              _FilterRow(
                period: _period,
                onPeriod: (p) => setState(() => _period = p),
                onDate: _soon,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SummaryCard(),
              const SizedBox(height: AppSpacing.lg),
              _DistributionCard(
                mode: _distMode,
                onMode: (m) => setState(() => _distMode = m),
                onMenu: _soon,
              ),
              const SizedBox(height: AppSpacing.lg),
              _TrendCard(onPeriod: _soon),
              const SizedBox(height: AppSpacing.lg),
              _CategoryAnalysisCard(onSeeAll: _soon),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onCalendar;

  const _TopBar({required this.onCalendar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 40),
        const Expanded(
          child: Center(
            child: Text(
              'İstatistikler',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        IconButton(
          onPressed: onCalendar,
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final int period;
  final ValueChanged<int> onPeriod;
  final VoidCallback onDate;

  const _FilterRow({
    required this.period,
    required this.onPeriod,
    required this.onDate,
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
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onDate,
            child: Container(
              height: 48,
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
                  Expanded(
                    child: Text(
                      'Mayıs 2025',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 18),
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
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _col('Toplam Gelir', 64450, 8.21, AppColors.success),
            _divider(),
            _col('Toplam Gider', 42150, 3.65, AppColors.error),
            _divider(),
            _col('Net Tasarruf', 22300, 12.45, AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.lg);

  Widget _col(String title, double amount, double percent, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
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
              Icon(Icons.arrow_upward, size: 13, color: color),
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
  final int mode;
  final ValueChanged<int> onMode;
  final VoidCallback onMenu;

  const _DistributionCard({
    required this.mode,
    required this.onMode,
    required this.onMenu,
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
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.more_vert, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
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
                          for (final c in _categoryStats)
                            PieChartSectionData(
                              value: c.percent.toDouble(),
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
                        const Text(
                          'Toplam Gider',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          Formatters.currency(42150).split(',').first,
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
                  children: [
                    for (final c in _categoryStats) _legendRow(c),
                  ],
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
        children: [
          _miniTab('Dağılım', 0),
          _miniTab('Karşılaştırma', 1),
        ],
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
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final VoidCallback onPeriod;

  const _TrendCard({required this.onPeriod});

  static const _labels = ['1 May', '8 May', '15 May', '22 May', '29 May', '31 May'];
  static const List<double> _income = [
    10000, 18000, 26000, 26000, 40000, 31000,
  ];
  static const List<double> _expense = [
    4000, 10000, 14000, 16000, 26000, 20000,
  ];

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
                  'Harcama Trendi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: onPeriod,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Bu Ay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(height: 200, child: _chart()),
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

  LineChartBarData _bar(List<double> values, Color color) {
    return LineChartBarData(
      spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
      isCurved: true,
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

  Widget _chart() {
    return LineChart(
      duration: AppDurations.slow,
      LineChartData(
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 50000,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10000,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10000,
              reservedSize: 34,
              getTitlesWidget: (v, _) => Text(
                v == 0 ? '0' : '${(v / 1000).toInt()}K',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10),
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
                if (i < 0 || i >= _labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    _labels[i],
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10),
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
          _bar(_income, AppColors.primary),
          _bar(_expense, AppColors.error),
        ],
      ),
    );
  }
}

class _CategoryAnalysisCard extends StatelessWidget {
  final VoidCallback onSeeAll;

  const _CategoryAnalysisCard({required this.onSeeAll});

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
                    Icon(Icons.chevron_right,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < _categoryStats.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _item(_categoryStats[i])),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _item(_categoryStats[i + 1])),
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
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
