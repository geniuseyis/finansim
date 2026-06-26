import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/entities/transaction_category.dart';

/// Kategorilerin görsel (ikon + renk) eşleşmesini presentation katmanında tutar.
///
/// İkon/renk Flutter'a (Material) özgü olduğu için domain'e konmaz; burada
/// bir extension ile ekleriz. Böylece domain saf Dart kalır.
extension TransactionCategoryUi on TransactionCategory {
  IconData get icon {
    switch (this) {
      case TransactionCategory.general:
        return Icons.account_balance_wallet_outlined;
      case TransactionCategory.salary:
        return Icons.work_outline;
      case TransactionCategory.investment:
        return Icons.show_chart;
      case TransactionCategory.freelance:
        return Icons.laptop_mac_outlined;
      case TransactionCategory.sales:
        return Icons.shopping_cart_outlined;
      case TransactionCategory.food:
        return Icons.restaurant_outlined;
      case TransactionCategory.transport:
        return Icons.directions_bus_outlined;
      case TransactionCategory.bills:
        return Icons.receipt_long_outlined;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.health:
        return Icons.favorite_outline;
      case TransactionCategory.entertainment:
        return Icons.movie_outlined;
      case TransactionCategory.education:
        return Icons.school_outlined;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.general:
      case TransactionCategory.salary:
        return AppColors.success;
      case TransactionCategory.investment:
      case TransactionCategory.food:
        return AppColors.warning;
      case TransactionCategory.freelance:
      case TransactionCategory.entertainment:
        return AppColors.accent;
      case TransactionCategory.sales:
      case TransactionCategory.bills:
      case TransactionCategory.shopping:
        return AppColors.primary;
      case TransactionCategory.transport:
      case TransactionCategory.education:
        return AppColors.secondary;
      case TransactionCategory.health:
        return AppColors.error;
      case TransactionCategory.other:
        return AppColors.textSecondary;
    }
  }
}
