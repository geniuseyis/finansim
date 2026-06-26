import 'package:flutter/material.dart';

/// Dashboard'da gösterilen özet metrik kartı (Gelir, Gider, Tasarruf, Yatırım).
class SummaryMetric {
  final String title;
  final double amount;
  final double changePercent;
  final IconData icon;
  final Color color;

  const SummaryMetric({
    required this.title,
    required this.amount,
    required this.changePercent,
    required this.icon,
    required this.color,
  });
}

/// Harcama grafiğindeki tek bir nokta (etiket + değer).
class SpendingPoint {
  final String label;
  final double value;

  const SpendingPoint(this.label, this.value);
}

/// Son işlemler listesinde gösterilen özet işlem satırı.
class RecentTxnItem {
  final String title;
  final String subtitle;
  final double amount; // gider için negatif
  final IconData icon;
  final Color color;

  const RecentTxnItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

/// Dashboard ekranının tüm verisini taşıyan görünüm modeli.
///
/// Şimdilik dummy repository'den beslenir; ileride gerçek API/Hive verisine
/// bağlanacak şekilde tasarlanmıştır (presentation katmanı değişmeden).
class DashboardViewData {
  final double totalBalance;
  final double balanceChangePercent;
  final List<SummaryMetric> metrics;
  final double monthlySpending;
  final double spendingChangePercent;
  final List<SpendingPoint> spendingTrend;
  final List<RecentTxnItem> recentTransactions;
  final String aiSuggestion;

  const DashboardViewData({
    required this.totalBalance,
    required this.balanceChangePercent,
    required this.metrics,
    required this.monthlySpending,
    required this.spendingChangePercent,
    required this.spendingTrend,
    required this.recentTransactions,
    required this.aiSuggestion,
  });
}
