import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../transactions/presentation/providers/finance_summary_provider.dart';

/// Gerçek finansal verilerden hesaplanmış öneri/skor paketi.
class AdvisorInsights {
  final int overall;
  final int incomeScore;
  final int savingsScore;
  final int spendingScore;
  final int budgetScore;
  final List<String> recommendations;

  const AdvisorInsights({
    required this.overall,
    required this.incomeScore,
    required this.savingsScore,
    required this.spendingScore,
    required this.budgetScore,
    required this.recommendations,
  });

  String get label => switch (overall) {
        >= 80 => 'Mükemmel',
        >= 65 => 'İyi',
        >= 50 => 'Orta',
        _ => 'Geliştirilmeli',
      };

  /// AI danışman fonksiyonuna gönderilen tek veri: 0-100 arası skorlar.
  Map<String, int> toScores() => {
        'overall': overall,
        'income': incomeScore,
        'savings': savingsScore,
        'spending': spendingScore,
        'budget': budgetScore,
      };
}

int _clamp100(num v) => v.clamp(0, 100).round();

final advisorInsightsProvider = Provider<AdvisorInsights>((ref) {
  final fs = ref.watch(financeSummaryProvider).value;
  final budget = ref.watch(budgetOverviewProvider).value;
  final goals = ref.watch(goalsOverviewProvider).value;

  final income = fs?.income ?? 0;
  final expense = fs?.expense ?? 0;
  final savingsRate = income > 0 ? (income - expense) / income : 0.0;

  // Tasarruf: %30 tasarruf = 100 puan.
  final savingsScore = _clamp100(savingsRate / 0.30 * 100);
  // Gelir yönetimi: net pozitifse yüksek.
  final incomeScore = income <= 0
      ? 40
      : _clamp100((income - expense) / income * 100 + 50);
  // Harcama kontrolü: gider artışı düştükçe yükselir.
  final expenseChange = fs?.expenseChange ?? 0;
  final spendingScore = _clamp100(100 - expenseChange.clamp(-50, 100));
  // Bütçe uyumu: kullanım %100 altındaysa iyi.
  final usage = budget?.usagePercent ?? 0;
  final budgetScore = budget == null || budget.isEmpty
      ? 70
      : _clamp100(100 - (usage - 100).clamp(0, 100));

  final overall = _clamp100(savingsScore * 0.35 +
      incomeScore * 0.20 +
      spendingScore * 0.20 +
      budgetScore * 0.25);

  // Kural tabanlı öneriler.
  final recs = <String>[];
  if (savingsRate < 0.2) {
    recs.add(
        'Tasarruf oranın %${(savingsRate * 100).round()} seviyesinde. Aylık gelirinin en az %20\'sini birikime ayırmayı dene.');
  } else {
    recs.add(
        'Tasarruf oranın iyi (%${(savingsRate * 100).round()}). Bu tempoyu koru!');
  }
  if (budget != null && budget.items.isNotEmpty) {
    final over = budget.items.where((b) => b.usagePercent >= 90).toList();
    if (over.isNotEmpty) {
      recs.add(
          '${over.first.category.label} kategorisinde bütçenin %${over.first.usagePercent}\'ini kullandın. Bu alanda harcamanı gözden geçir.');
    }
  } else {
    recs.add(
        'Henüz bütçe belirlememişsin. Kategori bazlı aylık limitler koymak harcamanı kontrol altına alır.');
  }
  if (goals != null && goals.active.isNotEmpty) {
    final g = goals.active.first;
    recs.add(
        '"${g.title}" hedefinde %${g.percent} yol katettin. Kalan ${Formatters.currency(g.remaining)} için düzenli birikim planla.');
  } else {
    recs.add(
        'Bir birikim hedefi belirlemek motivasyonunu artırır. Hedefler ekranından başlayabilirsin.');
  }
  if (expense > income && income > 0) {
    recs.add(
        'Bu dönem giderin gelirini aştı. Sabit olmayan harcamaları kısmayı düşün.');
  }

  return AdvisorInsights(
    overall: overall,
    incomeScore: incomeScore,
    savingsScore: savingsScore,
    spendingScore: spendingScore,
    budgetScore: budgetScore,
    recommendations: recs,
  );
});
