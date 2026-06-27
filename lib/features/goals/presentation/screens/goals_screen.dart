import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';

/// Aktif bir birikim hedefi (dummy veri).
class _Goal {
  final String title;
  final IconData icon;
  final Color color;
  final double target;
  final double saved;
  final int percent;
  final String date;
  final bool priority;

  const _Goal(this.title, this.icon, this.color, this.target, this.saved,
      this.percent, this.date, {this.priority = false});

  double get remaining => target - saved;
}

/// Tamamlanmış bir hedef (dummy veri).
class _CompletedGoal {
  final String title;
  final IconData icon;
  final Color color;
  final double amount;
  final String date;

  const _CompletedGoal(this.title, this.icon, this.color, this.amount,
      this.date);
}

const _activeGoals = <_Goal>[
  _Goal('Yeni Araba', Icons.directions_car_outlined, AppColors.primary, 450000,
      285300, 63, '15 Ara 2025', priority: true),
  _Goal('Ev Peşinatı', Icons.home_outlined, AppColors.success, 600000, 287400,
      48, '30 Haz 2026'),
  _Goal('Yurt Dışı Tatili', Icons.flight_takeoff, AppColors.accent, 120000,
      86400, 72, '10 Eyl 2025'),
  _Goal('Eğitim Fonu', Icons.school_outlined, AppColors.warning, 200000, 62400,
      31, '31 Ara 2026'),
];

const _completedGoals = <_CompletedGoal>[
  _CompletedGoal('Yeni Telefon', Icons.smartphone, AppColors.success, 25000,
      '12 Nis 2025'),
  _CompletedGoal('Dizüstü Bilgisayar', Icons.laptop_mac, AppColors.textSecondary,
      35000, '5 Mar 2025'),
];

/// Ekran 12 — Hedeflerim (tasarım birebir, dummy veri).
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int _tab = 0;

  void _soon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
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
          } else {
            _soon();
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onBell: () => context.push(AppRoutes.notifications)),
              const SizedBox(height: AppSpacing.lg),
              const _SummaryCard(),
              const SizedBox(height: AppSpacing.md),
              _TabBar(tab: _tab, onTap: (t) => setState(() => _tab = t)),
              const SizedBox(height: AppSpacing.md),
              _ActiveGoalsCard(onTapGoal: (_) => _soon()),
              const SizedBox(height: AppSpacing.lg),
              _CompletedGoalsCard(onSeeAll: _soon),
              const SizedBox(height: AppSpacing.lg),
              _CtaCard(onAdd: _soon),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBell;

  const _Header({required this.onBell});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hedeflerim',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Hayallerine bir adım daha yaklaş ✨',
                  style: textTheme.bodyMedium
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.track_changes,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text('Toplam Hedef Birikimi',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(Formatters.currency(126450),
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text('↑ %18,6',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Flexible(
                      child: Text('Geçen aya göre',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 120,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                const Text('Hedefe Ulaşma Oranı',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: 0.62,
                          strokeWidth: 6,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      const Text('62%',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text('4 / 6 Hedef',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTap;

  const _TabBar({required this.tab, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _tabItem(0, Icons.track_changes, 'Aktif Hedeflerim', 4),
          _tabItem(1, Icons.check_circle_outline, 'Tamamlananlar', 2),
          _tabItem(2, Icons.schedule, 'Gelecek Hedefler', 1),
        ],
      ),
    );
  }

  Widget _tabItem(int value, IconData icon, String label, int count) {
    final active = tab == value;
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withValues(alpha: 0.10) : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text('$count',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveGoalsCard extends StatelessWidget {
  final ValueChanged<_Goal> onTapGoal;

  const _ActiveGoalsCard({required this.onTapGoal});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          for (var i = 0; i < _activeGoals.length; i++) ...[
            _GoalRow(goal: _activeGoals[i], onTap: () => onTapGoal(_activeGoals[i])),
            if (i != _activeGoals.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final _Goal goal;
  final VoidCallback onTap;

  const _GoalRow({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: goal.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(goal.icon, color: goal.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(goal.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                ),
                                if (goal.priority) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: const Text('Öncelikli',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text('Hedef Tutar',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11)),
                            Text(Formatters.currency(goal.target),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(Formatters.currency(goal.saved),
                              style: TextStyle(
                                  color: goal.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('Kalan: ${Formatters.currency(goal.remaining)}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: goal.percent / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(goal.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('%${goal.percent}',
                          style: TextStyle(
                              color: goal.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(goal.date,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedGoalsCard extends StatelessWidget {
  final VoidCallback onSeeAll;

  const _CompletedGoalsCard({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Tamamlanan Hedefler',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Row(
                  children: [
                    Text('Tümü',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < _completedGoals.length; i++) ...[
            _CompletedRow(goal: _completedGoals[i]),
            if (i != _completedGoals.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _CompletedRow extends StatelessWidget {
  final _CompletedGoal goal;

  const _CompletedRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: goal.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(goal.icon, color: goal.color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(goal.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text('Tamamlandı',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Hedef Tutar: ${Formatters.currency(goal.amount)}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.currency(goal.amount),
                  style: const TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(goal.date,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.chevron_right,
              size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _CtaCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.track_changes,
                color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yeni bir hedef belirle',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                const Text(
                    'Hedeflerini belirle, birikimlerini takip et ve hayallerine ulaş!',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3)),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Hedef Ekle',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
