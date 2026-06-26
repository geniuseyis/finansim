import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../presentation/models/dashboard_view_data.dart';

/// Dashboard verisini sağlayan sözleşme. İleride gerçek (API/Hive) bir
/// implementasyon eklenebilir; UI yalnızca bu soyutlamayı tanır.
abstract interface class DashboardRepository {
  Future<DashboardViewData> getDashboardData();
}

/// Tasarımdaki referans değerleri döndüren geçici (dummy) implementasyon.
class DummyDashboardRepository implements DashboardRepository {
  const DummyDashboardRepository();

  @override
  Future<DashboardViewData> getDashboardData() async {
    // Gerçek bir ağ çağrısını taklit etmek için küçük gecikme.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return const DashboardViewData(
      totalBalance: 128420.50,
      balanceChangePercent: 12.45,
      monthlySpending: 42150.00,
      spendingChangePercent: -4.35,
      metrics: [
        SummaryMetric(
          title: 'Gelir',
          amount: 64450.00,
          changePercent: 8.21,
          icon: Icons.trending_up,
          color: AppColors.success,
        ),
        SummaryMetric(
          title: 'Gider',
          amount: 42150.00,
          changePercent: 3.65,
          icon: Icons.trending_down,
          color: AppColors.error,
        ),
        SummaryMetric(
          title: 'Tasarruf',
          amount: 22300.50,
          changePercent: 15.20,
          icon: Icons.savings_outlined,
          color: AppColors.accent,
        ),
        SummaryMetric(
          title: 'Yatırım',
          amount: 14800.00,
          changePercent: 5.12,
          icon: Icons.pie_chart_outline,
          color: AppColors.warning,
        ),
      ],
      spendingTrend: [
        SpendingPoint('1 May', 4000),
        SpendingPoint('8 May', 13000),
        SpendingPoint('15 May', 11000),
        SpendingPoint('22 May', 32000),
        SpendingPoint('29 May', 40000),
        SpendingPoint('31 May', 23000),
      ],
      recentTransactions: [
        RecentTxnItem(
          title: 'Migros',
          subtitle: 'Market • Bugün 14:32',
          amount: -245.50,
          icon: Icons.shopping_bag_outlined,
          color: AppColors.success,
        ),
        RecentTxnItem(
          title: 'Burger King',
          subtitle: 'Yemek • Bugün 12:18',
          amount: -190.00,
          icon: Icons.restaurant_outlined,
          color: AppColors.warning,
        ),
        RecentTxnItem(
          title: 'Elektrik Faturası',
          subtitle: 'Fatura • Dün 18:45',
          amount: -780.00,
          icon: Icons.bolt_outlined,
          color: AppColors.primary,
        ),
      ],
      aiSuggestion:
          'Bu ay restoran harcamaların %28 arttı. Tasarruf etmek için '
          'harcama limitini düşürebilirsin.',
    );
  }
}
