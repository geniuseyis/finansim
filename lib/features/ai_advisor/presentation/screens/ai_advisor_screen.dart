import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transactions/presentation/extensions/category_ui.dart';
import '../../../transactions/presentation/providers/finance_summary_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../../data/ai_advice_service.dart';
import '../providers/ai_advisor_provider.dart';

/// Ekran 22 — Yapay Zeka Finansal Öneriler.
class AiAdvisorScreen extends ConsumerStatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  ConsumerState<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends ConsumerState<AiAdvisorScreen> {
  final _advice = AiAdviceService();
  bool _analyzing = false;


  Future<void> _analyze() async {
    if (_analyzing) return;
    final insights = ref.read(advisorInsightsProvider);

    final fallback = insights.recommendations.map((r) => '• $r').join('\n\n');

    setState(() => _analyzing = true);
    try {
      final text = await _advice.analyze(insights.toScores());
      if (mounted) _showResult('AI Analizi', text);
    } catch (e) {
      // Fonksiyon kurulmamışsa ya da ağ yoksa cihazdaki kural tabanlı
      // öneriler gösterilir; kullanıcı hiçbir zaman boş ekranla kalmaz.
      if (mounted) {
        _showResult(
          'Kural Tabanlı Analiz',
          fallback,
          note: e is AiAdviceException ? e.message : 'Analiz yapılamadı.',
        );
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _showResult(String title, String body, {String? note}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.smart_toy_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(body, style: const TextStyle(height: 1.4)),
              if (note != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(note,
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _firstName() {
    final user = ref.watch(authStateProvider).value;
    final display = user?.displayName;
    if (display != null && display.trim().isNotEmpty) {
      return display.trim().split(' ').first;
    }
    final email = user?.email;
    if (email != null && email.contains('@')) {
      final local = email.split('@').first;
      return local.isEmpty ? local : local[0].toUpperCase() + local.substring(1);
    }
    return 'Kullanıcı';
  }

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(advisorInsightsProvider);
    final all = ref.watch(financeSummaryProvider).value;
    final month = all == null
        ? null
        : FinanceSummary.forPeriod(all.all, StatsPeriod.month);
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
          children: [
            _Header(onBell: () => context.push(AppRoutes.notifications)),
            const SizedBox(height: AppSpacing.lg),
            _WelcomeCard(
                name: _firstName(),
                analyzing: _analyzing,
                onAnalyze: _analyze),
            const SizedBox(height: AppSpacing.lg),
            _HealthCard(insights: insights, onDetails: _analyze),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle('Size Özel Öneriler'),
            const SizedBox(height: AppSpacing.sm),
            _RecommendationsCard(items: insights.recommendations),
            if (month != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _AnalysisRow(summary: month),
            ],
            const SizedBox(height: AppSpacing.lg),
            const _TipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Semantics(
        header: true,
        child: Text(t,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      );
}

class _Header extends StatelessWidget {
  final VoidCallback onBell;

  const _Header({required this.onBell});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppBackButton(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yapay Zeka Finansal Öneriler',
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: 4),
              Text('AI destekli kişisel finans önerilerinizi keşfedin',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        InkWell(
          onTap: onBell,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 28),
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  final bool analyzing;
  final VoidCallback onAnalyze;

  const _WelcomeCard(
      {required this.name, required this.analyzing, required this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Merhaba $name! 👋',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                    'Finansal verilerinizi analiz ettim ve size özel öneriler hazırladım.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3)),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: analyzing ? null : onAnalyze,
                  icon: analyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(analyzing ? 'Analiz ediliyor...' : 'AI ile Analiz Et'),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 104,
              height: 104,
              child: Image.asset(
                'assets/images/ai_robot.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: AppColors.primary, size: 44),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final AdvisorInsights insights;
  final VoidCallback onDetails;

  const _HealthCard({required this.insights, required this.onDetails});

  Color get _color => insights.overall >= 65
      ? AppColors.success
      : insights.overall >= 50
          ? AppColors.warning
          : AppColors.error;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Finansal Sağlık Skorunuz',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              GestureDetector(
                onTap: onDetails,
                child: const Text('AI ile Analiz Et',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: insights.overall / 100,
                            strokeWidth: 8,
                            backgroundColor: color.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(color),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${insights.overall}',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: color)),
                            Text(insights.label,
                                style: TextStyle(fontSize: 11, color: color)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Finansal sağlığın: ${insights.label} 💪',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                        insights.recommendations.isNotEmpty
                            ? insights.recommendations.first
                            : 'Verilerin analiz edildi.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                  child: _metric(Icons.account_balance_wallet_outlined,
                      AppColors.primary, 'Gelir Yönetimi', '${insights.incomeScore}')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: _metric(Icons.savings_outlined, AppColors.success,
                      'Tasarruf Oranı', '${insights.savingsScore}')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                  child: _metric(Icons.shopping_bag_outlined,
                      AppColors.warning, 'Harcama Kontrolü', '${insights.spendingScore}')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: _metric(Icons.credit_card, AppColors.accent,
                      'Bütçe Uyumu', '${insights.budgetScore}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, Color color, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text('İyi',
                          style: TextStyle(
                              fontSize: 9, color: AppColors.success)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.psychology_outlined,
                color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daha İyi Sonuçlar İçin İpuçları',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: AppSpacing.xs),
                _tip('Düzenli işlem ekleyerek analiz doğruluğunu artırın'),
                _tip('Hedeflerinizi belirleyin ve ilerlemenizi takip edin'),
                _tip('Kategori bütçeleri koyarak aşımları erken fark edin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3)),
            ),
          ],
        ),
      );
}

/// Ortak beyaz kart sarmalayıcı (yumuşak gölge).

/// Cihazdaki verilerden üretilen kural tabanlı öneriler.
class _RecommendationsCard extends StatelessWidget {
  final List<String> items;

  const _RecommendationsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            if (i != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

/// Bu ayın gerçek harcama dağılımı ve özeti.
class _AnalysisRow extends StatelessWidget {
  final FinanceSummary summary;

  const _AnalysisRow({required this.summary});

  List<(String, double, Color)> get _slices {
    final entries = summary.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(4).toList();
    final rest = entries.skip(4).fold<double>(0, (s, e) => s + e.value);
    return [
      for (final e in top) (e.key.label, e.value, e.key.color),
      if (rest > 0) ('Diğer', rest, const Color(0xFF64748B)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _spendingCard()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _summaryCard()),
        ],
      ),
    );
  }

  Widget _spendingCard() {
    final slices = _slices;
    final total = summary.expense;
    return _card(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Harcama Analizi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          if (slices.isEmpty)
            Expanded(
              child: Center(
                child: Text('Bu ay henüz gider yok.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
            )
          else ...[
            SizedBox(
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      sections: [
                        for (final s in slices)
                          PieChartSectionData(
                            value: s.$2,
                            color: s.$3,
                            title: '',
                            radius: 18,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Formatters.compactCurrency(total),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)),
                      Text('Toplam',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final s in slices)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: s.$3, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(s.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ),
                    Text('%${total > 0 ? (s.$2 / total * 100).round() : 0}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final income = summary.income;
    final net = summary.net;
    final rate = income > 0 ? (net / income * 100).round() : 0;
    final rows = [
      (Icons.show_chart, AppColors.primary, 'Toplam Harcama',
          Formatters.compactCurrency(summary.expense)),
      (Icons.north_east, AppColors.success, 'Toplam Gelir',
          Formatters.compactCurrency(income)),
      (Icons.percent, AppColors.accent, 'Tasarruf Oranı', '%$rate'),
      (Icons.savings_outlined, AppColors.warning, 'Net Birikim',
          Formatters.compactCurrency(net)),
    ];
    return _card(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bu Ayın Özeti',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: r.$2.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(r.$1, size: 14, color: r.$2),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(r.$3,
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ),
                  Text(r.$4,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}
