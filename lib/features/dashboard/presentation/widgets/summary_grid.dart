import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../models/dashboard_view_data.dart';

/// Gelir/Gider/Tasarruf/Yatırım metriklerini 2x2 ızgarada gösterir.
class SummaryGrid extends StatelessWidget {
  final List<SummaryMetric> metrics;

  const SummaryGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(metric: metrics[0])),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _MetricCard(metric: metrics[1])),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _MetricCard(metric: metrics[2])),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _MetricCard(metric: metrics[3])),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final SummaryMetric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(metric.icon, color: metric.color, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            metric.title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.currency(metric.amount),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                metric.changePercent >= 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 13,
                color: metric.color,
              ),
              const SizedBox(width: 2),
              Text(
                Formatters.percent(metric.changePercent),
                style: TextStyle(
                  color: metric.color,
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
