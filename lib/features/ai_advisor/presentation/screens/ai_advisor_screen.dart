import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';

const Color _pink = Color(0xFFEC4899);

/// Ekran 22 — Yapay Zeka Finansal Öneriler.
class AiAdvisorScreen extends ConsumerStatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  ConsumerState<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends ConsumerState<AiAdvisorScreen> {
  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
      );

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
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
        onAdd: () => context.push(AppRoutes.addTransaction),
        onTap: (i) {
          if (i == 0) {
            context.go(AppRoutes.dashboard);
          } else if (i == 1) {
            context.go(AppRoutes.transactions);
          } else if (i == 3) {
            context.push(AppRoutes.budget);
          } else if (i == 4) {
            context.push(AppRoutes.profile);
          } else {
            _soon();
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
          children: [
            _Header(onBell: () => context.push(AppRoutes.notifications)),
            const SizedBox(height: AppSpacing.lg),
            _WelcomeCard(name: _firstName(), onAnalyze: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analiz güncellendi.')),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            _HealthCard(onDetails: _soon),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle('Size Özel Öneriler', 'Tüm Önerileri Gör', _soon),
            const SizedBox(height: AppSpacing.sm),
            _RecommendationsCard(onTap: (_) => _soon()),
            const SizedBox(height: AppSpacing.lg),
            const _AnalysisRow(),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle('AI Analiz Özetiniz', 'Detaylı Rapor', _soon),
            const SizedBox(height: AppSpacing.sm),
            const _AiSummaryCarousel(),
            const SizedBox(height: AppSpacing.lg),
            _TipsCard(onAll: _soon),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t, String action, VoidCallback onAction) => Row(
        children: [
          Expanded(
            child: Text(t,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(action,
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ],
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
  final VoidCallback onAnalyze;

  const _WelcomeCard({required this.name, required this.onAnalyze});

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
                const Text(
                    'Finansal verilerinizi analiz ettim ve size özel öneriler hazırladım.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3)),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: onAnalyze,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Yenile ve Analiz Et'),
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
  final VoidCallback onDetails;

  const _HealthCard({required this.onDetails});

  @override
  Widget build(BuildContext context) {
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
                child: const Text('Detayları Gör',
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
                            value: 0.78,
                            strokeWidth: 8,
                            backgroundColor:
                                AppColors.success.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.success),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('78',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success)),
                            Text('İyi',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success)),
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
                  children: const [
                    Text('Finansal sağlığınız iyi durumda! 💪',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                        'Bazı küçük değişikliklerle daha da iyiye gidebilirsiniz.',
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
                      AppColors.primary, 'Gelir Yönetimi', '85')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: _metric(Icons.savings_outlined, AppColors.success,
                      'Tasarruf Oranı', '72')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                  child: _metric(Icons.shopping_bag_outlined,
                      AppColors.warning, 'Harcama Kontrolü', '75')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: _metric(Icons.credit_card, AppColors.accent,
                      'Borç Yönetimi', '80')),
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
                    style: const TextStyle(
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

class _RecommendationsCard extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _RecommendationsCard({required this.onTap});

  static const _items = [
    (Icons.savings_outlined, AppColors.success, 'Tasarruf Potansiyeli',
        'Aylık ₺1.250 tasarruf edebilirsiniz.', 'Yüksek Öncelik',
        AppColors.success),
    (Icons.credit_card, AppColors.warning, 'Abonelik Yönetimi',
        'Kullanmadığınız 2 abonelik tespit ettim.', 'Orta Öncelik',
        AppColors.warning),
    (Icons.track_changes, AppColors.accent, 'Yatırım Fırsatı',
        'Risk profilinize uygun yatırım önerisi.', 'Orta Öncelik',
        AppColors.accent),
    (Icons.shield_outlined, AppColors.primary, 'Güvenlik Önerisi',
        'Finansal güvenliğinizi artırın.', 'Düşük Öncelik', AppColors.primary),
  ];

  @override
  Widget build(BuildContext context) {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            _row(_items[i]),
            if (i != _items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _row((IconData, Color, String, String, String, Color) item) {
    return InkWell(
      onTap: () => onTap(item.$3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.$2.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.$1, color: item.$2, size: 22),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$3,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(item.$4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.$6.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(item.$5,
                  style: TextStyle(
                      color: item.$6,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow();

  static const _slices = [
    ('Konut & Faturalar', 27, AppColors.success),
    ('Yeme & İçme', 23, AppColors.primary),
    ('Ulaşım', 14, Color(0xFF94A3B8)),
    ('Alışveriş', 17, AppColors.accent),
    ('Eğlence', 9, _pink),
    ('Diğer', 10, Color(0xFF64748B)),
  ];

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
    return _card(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Harcama Analizi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
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
                      for (final s in _slices)
                        PieChartSectionData(
                          value: s.$2.toDouble(),
                          color: s.$3,
                          title: '',
                          radius: 18,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('₺12.450',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800)),
                    Text('Toplam',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final s in _slices)
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
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(s.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11)),
                  ),
                  Text('%${s.$2}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final rows = [
      (Icons.show_chart, AppColors.primary, 'Toplam Harcama', '₺12.450'),
      (Icons.north_east, AppColors.success, 'Toplam Gelir', '₺18.750'),
      (Icons.percent, AppColors.accent, 'Tasarruf Oranı', '%33'),
      (Icons.savings_outlined, AppColors.warning, 'Net Birikim', '₺6.300'),
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
                        style: const TextStyle(
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

class _AiSummaryCarousel extends StatelessWidget {
  const _AiSummaryCarousel();

  static const _cards = [
    (Icons.chat_bubble_outline, AppColors.primary, 'Harcama Analizi',
        'Bu ay yeme içme harcamalarınız geçen aya göre %18 arttı.'),
    (Icons.savings_outlined, AppColors.success, 'Tasarruf Önerisi',
        'Ulaşım masraflarınızı azaltarak ayda ₺450 tasarruf edebilirsiniz.'),
    (Icons.track_changes, AppColors.accent, 'Hedef Önerisi',
        'Acil durum fonu oluşturmanızı öneriyoruz.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final c = _cards[i];
              return Container(
                width: 240,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c.$2.withValues(alpha: 0.14),
                      c.$2.withValues(alpha: 0.04),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c.$2.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(c.$1, size: 16, color: c.$2),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(c.$3,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(c.$4,
                        maxLines: 3,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.3)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == 0 ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == 0
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  final VoidCallback onAll;

  const _TipsCard({required this.onAll});

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
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: onAll,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                  ),
                  child: const Text('Tüm İpuçlarını Gör'),
                ),
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
            const Text('• ',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3)),
            ),
          ],
        ),
      );
}

/// Ortak beyaz kart sarmalayıcı (yumuşak gölge).
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
