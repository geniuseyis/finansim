import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../models/dashboard_view_data.dart';

/// Son işlemleri listeleyen kart.
class RecentTransactionsCard extends StatelessWidget {
  final List<RecentTxnItem> transactions;
  final VoidCallback onSeeAll;
  final ValueChanged<RecentTxnItem> onTap;

  const RecentTransactionsCard({
    super.key,
    required this.transactions,
    required this.onSeeAll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Son İşlemler',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < transactions.length; i++) ...[
            _TransactionRow(item: transactions[i], onTap: () => onTap(transactions[i])),
            if (i != transactions.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final RecentTxnItem item;
  final VoidCallback onTap;

  const _TransactionRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncome = item.amount >= 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${Formatters.currency(item.amount.abs())}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.success : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
