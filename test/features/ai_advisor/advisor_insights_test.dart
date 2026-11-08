import 'package:financeapp/features/ai_advisor/presentation/providers/ai_advisor_provider.dart';
import 'package:flutter_test/flutter_test.dart';

AdvisorInsights insights(int overall) => AdvisorInsights(
      overall: overall,
      incomeScore: 1,
      savingsScore: 2,
      spendingScore: 3,
      budgetScore: 4,
      recommendations: const [],
    );

void main() {
  group('AdvisorInsights', () {
    test('etiket eşikleri', () {
      expect(insights(80).label, 'Mükemmel');
      expect(insights(79).label, 'İyi');
      expect(insights(65).label, 'İyi');
      expect(insights(50).label, 'Orta');
      expect(insights(49).label, 'Geliştirilmeli');
    });
  });
}
