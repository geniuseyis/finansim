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
import '../../domain/recurring_payment.dart';
import '../providers/recurring_providers.dart';

/// Servis adına göre marka ikonu + rengi.
(IconData, Color) _brandFor(String title) {
  final t = title.toLowerCase();
  if (t.contains('netflix')) return (Icons.movie_outlined, const Color(0xFFE50914));
  if (t.contains('spotify')) return (Icons.music_note, const Color(0xFF1DB954));
  if (t.contains('youtube')) return (Icons.smart_display_outlined, const Color(0xFFFF0000));
  if (t.contains('adobe')) return (Icons.brush_outlined, const Color(0xFFFF3B30));
  if (t.contains('icloud') || t.contains('apple')) return (Icons.cloud_outlined, AppColors.primary);
  if (t.contains('amazon') || t.contains('prime')) return (Icons.shopping_cart_outlined, AppColors.warning);
  if (t.contains('gym') || t.contains('spor')) return (Icons.fitness_center, const Color(0xFF1F2937));
  if (t.contains('turkcell') || t.contains('telefon') || t.contains('hat')) return (Icons.sim_card_outlined, AppColors.warning);
  if (t.contains('internet') || t.contains('wifi')) return (Icons.wifi, AppColors.primary);
  if (t.contains('elektrik')) return (Icons.bolt_outlined, AppColors.warning);
  if (t.contains('su ') || t == 'su') return (Icons.water_drop_outlined, AppColors.primary);
  if (t.contains('kira')) return (Icons.home_outlined, AppColors.accent);
  if (t.contains('sigorta')) return (Icons.shield_outlined, AppColors.success);
  return (Icons.autorenew, AppColors.primary);
}

enum _Filter { all, active, upcoming, paused, completed }

/// Ekran 20 — Tekrarlayan Ödemeler (gerçek veri, Hive).
class RecurringPaymentsScreen extends ConsumerStatefulWidget {
  const RecurringPaymentsScreen({super.key});

  @override
  ConsumerState<RecurringPaymentsScreen> createState() =>
      _RecurringPaymentsScreenState();
}

class _RecurringPaymentsScreenState
    extends ConsumerState<RecurringPaymentsScreen> {
  final _searchController = TextEditingController();
  _Filter _filter = _Filter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
      );

  Future<void> _openAddSheet() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _AddRecurringSheet(),
      );

  List<RecurringPayment> _applyQuery(List<RecurringPayment> list) {
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(recurringOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xs),
            child: FilledButton.icon(
              onPressed: _openAddSheet,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Tekrarlayan Ödeme Ekle'),
            ),
          ),
          AppBottomNav(
            currentIndex: -1,
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (o) => _buildContent(o),
        ),
      ),
    );
  }

  Widget _buildContent(RecurringOverview o) {
    final single = switch (_filter) {
      _Filter.active => o.active,
      _Filter.upcoming => o.upcoming,
      _Filter.paused =>
        o.all.where((p) => p.status == PaymentStatus.paused).toList(),
      _Filter.completed =>
        o.all.where((p) => p.status == PaymentStatus.completed).toList(),
      _Filter.all => <RecurringPayment>[],
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      children: [
        _Header(onBell: () => context.push(AppRoutes.notifications)),
        const SizedBox(height: AppSpacing.lg),
        _SearchRow(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          onFilter: _soon,
        ),
        const SizedBox(height: AppSpacing.md),
        _FilterTabs(
          filter: _filter,
          onChanged: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: AppSpacing.md),
        _SummaryCard(overview: o),
        const SizedBox(height: AppSpacing.lg),
        if (o.all.isEmpty)
          const _EmptyState()
        else if (_filter == _Filter.all && _query.isEmpty) ...[
          if (o.upcoming.isNotEmpty) ...[
            _sectionTitle('Yaklaşan Ödemeler'),
            const SizedBox(height: AppSpacing.sm),
            _UpcomingCard(items: o.upcoming, onTap: (_) => _soon()),
            const SizedBox(height: AppSpacing.lg),
          ],
          _sectionTitle('Aktif Ödemeler'),
          const SizedBox(height: AppSpacing.sm),
          _ActiveCard(items: o.active, onTap: (_) => _soon()),
        ] else ...[
          _sectionTitle(_filterTitle()),
          const SizedBox(height: AppSpacing.sm),
          _ActiveCard(items: _applyQuery(single), onTap: (_) => _soon()),
        ],
        const SizedBox(height: AppSpacing.lg),
        _InfoCard(onReport: _soon),
      ],
    );
  }

  String _filterTitle() => switch (_filter) {
        _Filter.active => 'Aktif Ödemeler',
        _Filter.upcoming => 'Yaklaşan Ödemeler',
        _Filter.paused => 'Durdurulan Ödemeler',
        _Filter.completed => 'Tamamlanan Ödemeler',
        _Filter.all => 'Tüm Ödemeler',
      };

  Widget _sectionTitle(String t) => Row(
        children: [
          Expanded(
            child: Text(t,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          const Row(
            children: [
              Text('Tümünü Gör',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
            ],
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
              Text('Tekrarlayan Ödemeler',
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Düzenli ödemelerinizi yönetin',
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

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Ödeme ara...',
              prefixIcon:
                  Icon(Icons.search, color: AppColors.textSecondary),
              fillColor: AppColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onFilter,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.tune, size: 18, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text('Filtrele',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _Filter filter;
  final ValueChanged<_Filter> onChanged;

  const _FilterTabs({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (_Filter.all, Icons.grid_view_rounded, 'Tümü', AppColors.primary),
      (_Filter.active, Icons.play_circle_outline, 'Aktif', AppColors.success),
      (_Filter.upcoming, Icons.schedule, 'Yaklaşan', AppColors.warning),
      (_Filter.paused, Icons.pause_circle_outline, 'Durdurulan',
          AppColors.error),
      (_Filter.completed, Icons.check_circle_outline, 'Tamamlanan',
          AppColors.accent),
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in tabs)
              GestureDetector(
                onTap: () => onChanged(t.$1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: filter == t.$1
                        ? t.$4.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(t.$2,
                          size: 16,
                          color: filter == t.$1
                              ? t.$4
                              : AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(t.$3,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: filter == t.$1
                                  ? t.$4
                                  : AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final RecurringOverview overview;

  const _SummaryCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final next = overview.next;
    final nextDays = next == null
        ? '-'
        : next.daysLeft == 0
            ? 'Bugün'
            : '${next.daysLeft} gün';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _col(Icons.autorenew, AppColors.primary, 'Toplam Ödeme',
                Formatters.currency(overview.monthlyTotal), 'Aylık toplam'),
            _divider(),
            _col(Icons.play_circle_outline, AppColors.success,
                'Aktif Ödemeler', '${overview.activeCount}', 'Düzenli ödeme'),
            _divider(),
            _col(Icons.calendar_today_outlined, AppColors.warning,
                'Yaklaşan Ödeme', Formatters.currency(overview.upcomingTotal),
                '${overview.upcoming.length} ödeme'),
            _divider(),
            _col(Icons.access_time, AppColors.accent, 'Sonraki Ödeme', nextDays,
                next?.title ?? '-', plain: true),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.md);

  Widget _col(IconData icon, Color color, String title, String value,
      String sub, {bool plain = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: plain ? AppColors.textPrimary : color)),
          ),
          Text(sub,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 9, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final List<RecurringPayment> items;
  final ValueChanged<RecurringPayment> onTap;

  const _UpcomingCard({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _row(items[i]),
            if (i != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _row(RecurringPayment p) {
    final brand = _brandFor(p.title);
    final days = p.daysLeft;
    final (daysText, daysColor) = days < 0
        ? ('${-days} gün gecikti', AppColors.error)
        : days == 0
            ? ('Bugün', AppColors.primary)
            : ('$days gün kaldı', AppColors.warning);

    return InkWell(
      onTap: () => onTap(p),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: brand.$2.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(brand.$1, color: brand.$2, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(p.category,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.longDate(p.nextDate),
                    style: const TextStyle(fontSize: 11)),
                Text(daysText,
                    style: TextStyle(
                        color: daysColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(Formatters.currency(p.amount),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  final List<RecurringPayment> items;
  final ValueChanged<RecurringPayment> onTap;

  const _ActiveCard({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text('Kayıt yok.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _row(items[i]),
            if (i != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _row(RecurringPayment p) {
    final brand = _brandFor(p.title);
    final statusColor = switch (p.status) {
      PaymentStatus.active => AppColors.success,
      PaymentStatus.paused => AppColors.error,
      PaymentStatus.completed => AppColors.accent,
    };
    return InkWell(
      onTap: () => onTap(p),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: brand.$2.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(brand.$1, color: brand.$2, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(p.status.label,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  Text(p.category,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(p.frequency.label,
                    style: const TextStyle(fontSize: 11)),
                Text('Sonraki: ${Formatters.longDate(p.nextDate)}',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(Formatters.currency(p.amount),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final VoidCallback onReport;

  const _InfoCard({required this.onReport});

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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.event_repeat,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ödemelerinizi Kontrol Altında Tutun',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                    'Tekrarlayan ödemelerinizi düzenli olarak gözden geçirin ve bütçenizi koruyun.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onReport,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Raporu Gör',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                  Icon(Icons.chevron_right, color: Colors.white, size: 16),
                ],
              ),
            ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_repeat,
                size: 64, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            Text('Henüz tekrarlayan ödeme yok',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            SizedBox(height: AppSpacing.xs),
            Text('Aboneliklerini ve düzenli faturalarını ekleyerek başla.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// Yeni tekrarlayan ödeme ekleme alt sayfası.
class _AddRecurringSheet extends ConsumerStatefulWidget {
  const _AddRecurringSheet();

  @override
  ConsumerState<_AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends ConsumerState<_AddRecurringSheet> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  PaymentFrequency _frequency = PaymentFrequency.monthly;
  DateTime _firstDate = DateTime.now().add(const Duration(days: 1));

  static const _quick = [
    ('Netflix', 'Eğlence'),
    ('Spotify Premium', 'Müzik'),
    ('YouTube Premium', 'Eğlence'),
    ('Adobe Creative Cloud', 'Yazılım'),
    ('Apple iCloud+', 'Depolama'),
    ('Amazon Prime', 'Alışveriş'),
    ('Gym Membership', 'Spor'),
    ('İnternet', 'İletişim'),
    ('Elektrik', 'Fatura'),
    ('Kira', 'Konut'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _firstDate = picked);
  }

  Future<void> _save() async {
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
    if (_titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad ve geçerli tutar gerekli.')),
      );
      return;
    }
    final payment = RecurringPayment(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      amount: amount,
      frequency: _frequency,
      nextDate: _firstDate,
    );
    await ref.read(recurringServiceProvider).save(payment);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Yeni Tekrarlayan Ödeme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quick.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, i) {
                  final q = _quick[i];
                  final brand = _brandFor(q.$1);
                  return ActionChip(
                    avatar: Icon(brand.$1, size: 16, color: brand.$2),
                    label: Text(q.$1, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _titleController.text = q.$1;
                      _categoryController.text = q.$2;
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Servis / Ödeme adı'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Tutar',
                prefixText: '₺',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<PaymentFrequency>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Sıklık'),
              items: [
                for (final f in PaymentFrequency.values)
                  DropdownMenuItem(value: f, child: Text(f.label)),
              ],
              onChanged: (v) => setState(() => _frequency = v ?? _frequency),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.input),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text('İlk ödeme: ${Formatters.longDate(_firstDate)}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: _save, child: const Text('Kaydet')),
          ],
        ),
      ),
    );
  }
}
