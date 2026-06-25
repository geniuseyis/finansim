import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';
import '../extensions/category_ui.dart';

/// Listede tek bir işlemi gösteren satır.
///
/// Gelir yeşil ve "+", gider kırmızı ve "-" ile vurgulanır; kategori ikonu
/// sol tarafta dairesel bir rozet içinde gösterilir.
class TransactionListItem extends StatelessWidget {
  final AppTransaction transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final sign = isIncome ? '+' : '-';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(transaction.category.icon, color: color),
      ),
      title: Text(
        transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.category.label} • ${Formatters.date(transaction.date)}',
      ),
      trailing: Text(
        '$sign${Formatters.currency(transaction.amount)}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
