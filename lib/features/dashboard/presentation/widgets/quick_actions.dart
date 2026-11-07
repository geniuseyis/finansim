import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

/// Tek bir hızlı işlem öğesinin verisi.
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// 5 dairesel hızlı işlem butonu içeren beyaz kart.
class QuickActions extends StatelessWidget {
  final VoidCallback onIncome;
  final VoidCallback onExpense;
  final VoidCallback onRates;
  final VoidCallback onScan;
  final VoidCallback onAll;

  const QuickActions({
    super.key,
    required this.onIncome,
    required this.onExpense,
    required this.onRates,
    required this.onScan,
    required this.onAll,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickAction(
        icon: Icons.add,
        label: 'Gelir Ekle',
        color: AppColors.success,
        onTap: onIncome,
      ),
      QuickAction(
        icon: Icons.remove,
        label: 'Gider Ekle',
        color: AppColors.error,
        onTap: onExpense,
      ),
      QuickAction(
        icon: Icons.currency_exchange,
        label: 'Döviz',
        color: AppColors.primary,
        onTap: onRates,
      ),
      QuickAction(
        icon: Icons.document_scanner_outlined,
        label: 'Makbuz Tara',
        color: AppColors.accent,
        onTap: onScan,
      ),
      QuickAction(
        icon: Icons.more_horiz,
        label: 'Tümü',
        color: AppColors.textSecondary,
        onTap: onAll,
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: actions
            .map((a) => Expanded(child: _QuickActionButton(action: a)))
            .toList(),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
