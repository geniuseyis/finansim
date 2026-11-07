import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../../domain/savings_goal.dart';
import '../providers/goals_providers.dart';

/// Hedef kategorisi: anahtar, etiket, ikon, renk.
const _categories = <(String, String, IconData, Color)>[
  ('car', 'Araba', Icons.directions_car_outlined, AppColors.primary),
  ('home', 'Ev', Icons.home_outlined, AppColors.success),
  ('travel', 'Tatil', Icons.flight_takeoff, AppColors.accent),
  ('education', 'Eğitim', Icons.school_outlined, AppColors.warning),
  ('tech', 'Teknoloji', Icons.devices_other, AppColors.primary),
  ('wedding', 'Düğün', Icons.favorite_outline, AppColors.error),
  ('emergency', 'Acil Fon', Icons.health_and_safety_outlined, AppColors.error),
  ('savings', 'Birikim', Icons.savings_outlined, AppColors.success),
  ('other', 'Diğer', Icons.star_outline, AppColors.primary),
];

/// Anahtara göre ikon + renk döndürür.
(IconData, Color) _visual(String key) {
  for (final c in _categories) {
    if (c.$1 == key) return (c.$3, c.$4);
  }
  return (Icons.star_outline, AppColors.primary);
}

const _months = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String _shortDate(DateTime? d) =>
    d == null ? 'Tarih yok' : '${d.day} ${_months[d.month - 1]} ${d.year}';

/// Ekran 12 — Hedeflerim (gerçek veri, Hive).
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  int _tab = 0;

  Future<void> _openAddSheet() async {
    final goal = await showModalBottomSheet<SavingsGoal>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddGoalSheet(),
    );
    if (goal != null) {
      await ref.read(goalsServiceProvider).save(goal);
    }
  }

  Future<void> _openGoalSheet(SavingsGoal goal) async {
    final action = await showModalBottomSheet<_GoalAction>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _GoalActionsSheet(goal: goal),
    );
    if (action == null) return;
    final service = ref.read(goalsServiceProvider);
    switch (action) {
      case _AddMoney(:final amount):
        await service.addContribution(goal, amount);
      case _TogglePriority():
        await service.save(goal.copyWith(priority: !goal.priority));
      case _Delete():
        await service.delete(goal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(goalsOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
      ),
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: _buildContent,
        ),
      ),
    );
  }

  Widget _buildContent(GoalsOverview o) {
    final list = switch (_tab) {
      1 => o.completed,
      2 => o.upcoming,
      _ => o.active,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(onBell: () => context.push(AppRoutes.notifications)),
          const SizedBox(height: AppSpacing.lg),
          _SummaryCard(overview: o),
          const SizedBox(height: AppSpacing.md),
          _TabBar(
            tab: _tab,
            counts: [o.active.length, o.completedCount, o.upcoming.length],
            onTap: (t) => setState(() => _tab = t),
          ),
          const SizedBox(height: AppSpacing.md),
          if (o.totalCount == 0)
            const _EmptyState()
          else if (list.isEmpty)
            _emptyTab()
          else if (_tab == 1)
            _CompletedList(goals: list)
          else
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    _GoalRow(
                        goal: list[i], onTap: () => _openGoalSheet(list[i])),
                    if (i != list.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _CtaCard(onAdd: _openAddSheet),
        ],
      ),
    );
  }

  Widget _emptyTab() {
    final msg = switch (_tab) {
      1 => 'Henüz tamamlanan hedef yok.',
      2 => 'Planlanan (henüz birikim yapılmamış) hedef yok.',
      _ => 'Aktif hedef yok. Yeni bir hedef ekleyerek başla!',
    };
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.flag_outlined, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(msg,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

/// Hedef satırına dokununca seçilen işlem.
sealed class _GoalAction {
  const _GoalAction();
}

class _AddMoney extends _GoalAction {
  final double amount;
  const _AddMoney(this.amount);
}

class _TogglePriority extends _GoalAction {
  const _TogglePriority();
}

class _Delete extends _GoalAction {
  const _Delete();
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
                      border: Border.all(color: AppColors.background, width: 2),
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
  final GoalsOverview overview;

  const _SummaryCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final o = overview;
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
                    Expanded(
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
                  child: Text(Formatters.currency(o.totalSaved),
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
                      child: Text('%${o.overallPercent} tamamlandı',
                          style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                          'Hedef: ${Formatters.currency(o.totalTarget)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                Text('Hedefe Ulaşma Oranı',
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
                          value: o.overallPercent / 100,
                          strokeWidth: 6,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text('%${o.overallPercent}',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('${o.completedCount} / ${o.totalCount} Hedef',
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
  final List<int> counts;
  final ValueChanged<int> onTap;

  const _TabBar({required this.tab, required this.counts, required this.onTap});

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
          _tabItem(0, Icons.track_changes, 'Aktif Hedeflerim', counts[0]),
          _tabItem(1, Icons.check_circle_outline, 'Tamamlananlar', counts[1]),
          _tabItem(2, Icons.schedule, 'Gelecek Hedefler', counts[2]),
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

class _GoalRow extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;

  const _GoalRow({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visual(goal.iconKey);
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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
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
                            Text('Hedef Tutar',
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
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('Kalan: ${Formatters.currency(goal.remaining)}',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.chevron_right,
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
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('%${goal.percent}',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(_shortDate(goal.targetDate),
                          style: TextStyle(
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

class _CompletedList extends StatelessWidget {
  final List<SavingsGoal> goals;

  const _CompletedList({required this.goals});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (var i = 0; i < goals.length; i++) ...[
            _CompletedRow(goal: goals[i]),
            if (i != goals.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _CompletedRow extends StatelessWidget {
  final SavingsGoal goal;

  const _CompletedRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visual(goal.iconKey);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.success, size: 22),
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
                          style: const TextStyle(fontWeight: FontWeight.w600)),
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
                Text('Hedef Tutar: ${Formatters.currency(goal.target)}',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.currency(goal.saved),
                  style: const TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(_shortDate(goal.targetDate),
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Henüz hedef yok',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'İlk birikim hedefini ekle ve hayallerine ulaşmaya başla.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
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
                Text(
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

/// Yeni hedef ekleme alt sayfası.
class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet();

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _savedController = TextEditingController();
  String _iconKey = 'car';
  DateTime? _date;
  bool _priority = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll('.', '').replaceAll(',', '.')) ??
      0;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 180)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    final target = _parse(_targetController);
    if (title.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen hedef adı ve tutarını gir.')),
      );
      return;
    }
    final goal = SavingsGoal(
      id: const Uuid().v4(),
      title: title,
      iconKey: _iconKey,
      target: target,
      saved: _parse(_savedController).clamp(0, target).toDouble(),
      targetDate: _date,
      priority: _priority,
      createdAt: DateTime.now(),
    );
    Navigator.pop(context, goal);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            const Center(
              child: Text('Yeni Hedef',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Hedef Adı',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Örn. Yeni Araba'),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Kategori',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final c in _categories)
                  ChoiceChip(
                    avatar: Icon(c.$3,
                        size: 18,
                        color: _iconKey == c.$1 ? Colors.white : c.$4),
                    label: Text(c.$2),
                    selected: _iconKey == c.$1,
                    onSelected: (_) => setState(() => _iconKey = c.$1),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hedef Tutar (₺)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: const InputDecoration(hintText: '0'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mevcut Birikim (₺)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _savedController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: const InputDecoration(hintText: '0'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(_date == null
                        ? 'Hedef Tarihi (opsiyonel)'
                        : _shortDate(_date)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Öncelikli hedef'),
              value: _priority,
              onChanged: (v) => setState(() => _priority = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Hedefi Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hedef işlemleri alt sayfası (para ekle / öncelik / sil).
class _GoalActionsSheet extends StatefulWidget {
  final SavingsGoal goal;

  const _GoalActionsSheet({required this.goal});

  @override
  State<_GoalActionsSheet> createState() => _GoalActionsSheetState();
}

class _GoalActionsSheetState extends State<_GoalActionsSheet> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addMoney() {
    final amount = double.tryParse(
            _amountController.text.trim().replaceAll('.', '').replaceAll(',', '.')) ??
        0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir tutar gir.')),
      );
      return;
    }
    Navigator.pop(context, _AddMoney(amount));
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;
    final (icon, color) = _visual(g.iconKey);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(
                        '${Formatters.currency(g.saved)} / ${Formatters.currency(g.target)} (%${g.percent})',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: g.percent / 100,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Birikim Ekle',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                      prefixText: '₺ ', hintText: '0'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: _addMoney,
                child: const Text('Ekle'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pop(context, const _TogglePriority()),
                  icon: Icon(
                      g.priority ? Icons.star : Icons.star_border, size: 18),
                  label: Text(g.priority ? 'Önceliği Kaldır' : 'Öncelikli Yap'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Hedefi Sil'),
                        content: Text(
                            '"${g.title}" hedefini silmek istiyor musun?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Vazgeç')),
                          FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sil')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      Navigator.pop(context, const _Delete());
                    }
                  },
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  label: const Text('Sil',
                      style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
