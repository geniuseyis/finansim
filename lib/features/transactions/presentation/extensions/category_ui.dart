import 'package:flutter/material.dart';

import '../../domain/entities/transaction_category.dart';

/// Kategorilerin görsel (ikon) eşleşmesini presentation katmanında tutar.
///
/// İkonlar Flutter'a (Material) özgü olduğu için domain'e konmaz; burada
/// bir extension ile ekleriz. Böylece domain saf Dart kalır.
extension TransactionCategoryUi on TransactionCategory {
  IconData get icon {
    switch (this) {
      case TransactionCategory.salary:
        return Icons.payments_outlined;
      case TransactionCategory.investment:
        return Icons.trending_up;
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
        return Icons.category_outlined;
    }
  }
}
