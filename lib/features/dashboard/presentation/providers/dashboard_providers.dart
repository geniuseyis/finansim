import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/extensions/category_ui.dart';
import '../../../transactions/presentation/providers/finance_summary_provider.dart';
import '../models/dashboard_view_data.dart';

/// Dashboard verisini gerçek işlemlerden (FinanceSummary) türetir.
final dashboardDataProvider = Provider<AsyncValue<DashboardViewData>>((ref) {
  return ref.watch(financeSummaryProvider).whenData(_mapToDashboard);
});

DashboardViewData _mapToDashboard(FinanceSummary s) {
  return DashboardViewData(
    totalBalance: s.balance,
    balanceChangePercent: s.netChange,
    monthlySpending: s.expense,
    spendingChangePercent: s.expenseChange,
    metrics: [
      SummaryMetric(
        title: 'Gelir',
        amount: s.income,
        changePercent: s.incomeChange,
        icon: Icons.trending_up,
        color: AppColors.success,
      ),
      SummaryMetric(
        title: 'Gider',
        amount: s.expense,
        changePercent: s.expenseChange,
        icon: Icons.trending_down,
        color: AppColors.error,
      ),
      SummaryMetric(
        title: 'Tasarruf',
        amount: s.net,
        changePercent: s.netChange,
        icon: Icons.savings_outlined,
        color: AppColors.accent,
      ),
      SummaryMetric(
        title: 'Yatırım',
        amount: s.investment,
        changePercent: s.investmentChange,
        icon: Icons.pie_chart_outline,
        color: AppColors.warning,
      ),
    ],
    spendingTrend: [
      for (final p in s.dailyTrend(7, type: TransactionType.expense))
        SpendingPoint(p.label, p.value),
    ],
    recentTransactions: [
      for (final t in s.recent(4))
        RecentTxnItem(
          title: t.title,
          subtitle: '${t.category.label} • ${Formatters.date(t.date)}',
          amount: t.signedAmount,
          icon: t.category.icon,
          color: t.category.color,
          source: t,
        ),
    ],
    aiSuggestion: _buildSuggestion(s),
  );
}

/// İşlem verisine göre basit, kural tabanlı bir öneri üretir
/// (gerçek yapay zeka entegrasyonu ileriki fazda eklenecek).
String _buildSuggestion(FinanceSummary s) {
  if (s.all.isEmpty) {
    return 'İlk işlemini ekleyerek finansal takibe başla. '
        'Harcamaların burada analiz edilecek.';
  }
  if (s.expense > s.income) {
    return 'Bu dönem giderlerin gelirini aştı. Harcama kategorilerini '
        'gözden geçirip bir bütçe limiti belirleyebilirsin.';
  }
  return 'Harika gidiyorsun! Gelirinin bir kısmını tasarruf hedefine '
      'ayırarak birikimini büyütebilirsin.';
}
