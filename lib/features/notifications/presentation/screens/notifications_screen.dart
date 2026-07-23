import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../providers/notifications_provider.dart';

bool _isTxn(AppNotification n) => n.title.contains('Eklendi');

/// Ekran 18 — Bildirimler (gerçek verilerden üretilir).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _filter = 0;
  final Set<int> _read = {};

  bool _belongsToTab(AppNotification n) => switch (_filter) {
        1 => n.important,
        2 => _isTxn(n),
        3 => !_isTxn(n) && !n.important,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(notificationsProvider);
    final counts = [
      all.length,
      all.where((n) => n.important).length,
      all.where(_isTxn).length,
      all.where((n) => !_isTxn(n) && !n.important).length,
    ];

    final filtered = all.where(_belongsToTab).toList();
    final important = filtered.where((n) => n.important).toList();
    final others = filtered.where((n) => !n.important).toList();

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
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onSettings: () => context.push(AppRoutes.settings)),
              const SizedBox(height: AppSpacing.lg),
              _FilterBar(
                filter: _filter,
                counts: counts,
                onChanged: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (all.isEmpty)
                const _EmptyState()
              else ...[
                if (important.isNotEmpty) ...[
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Önemli Bildirimler',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _read
                            .addAll(List.generate(important.length, (i) => i))),
                        child: const Text('Tümünü Okundu İşaretle',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (var i = 0; i < important.length; i++) ...[
                    _ImportantCard(
                      item: important[i],
                      unread: !_read.contains(i),
                      onTap: () => setState(() => _read.add(i)),
                    ),
                    if (i != important.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
                ..._buildGroups(others),
                if (others.isEmpty && important.isEmpty) const _EmptyFilter(),
              ],
              const SizedBox(height: AppSpacing.lg),
              _BottomCard(
                  onOpenSettings: () => context.push(AppRoutes.settings)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroups(List<AppNotification> items) {
    if (items.isEmpty) return [];
    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final earlier = <AppNotification>[];
    for (final n in items) {
      if (sameDay(n.when, now)) {
        today.add(n);
      } else if (sameDay(n.when, now.subtract(const Duration(days: 1)))) {
        yesterday.add(n);
      } else {
        earlier.add(n);
      }
    }
    Widget section(String title, List<AppNotification> list) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            _NotifGroup(items: list),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
    return [
      if (today.isNotEmpty) section('Bugün', today),
      if (yesterday.isNotEmpty) section('Dün', yesterday),
      if (earlier.isNotEmpty) section('Daha Önce', earlier),
    ];
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onSettings;

  const _Header({required this.onSettings});

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
              Text('Bildirimler',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Tüm bildirimlerini görüntüle',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onSettings,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.settings_outlined, size: 22),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final int filter;
  final List<int> counts;
  final ValueChanged<int> onChanged;

  const _FilterBar(
      {required this.filter, required this.counts, required this.onChanged});

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
          _tab(0, Icons.notifications_none, 'Tümü', counts[0],
              AppColors.primary),
          _tab(1, Icons.error_outline, 'Önemli', counts[1], AppColors.error),
          _tab(2, Icons.swap_horiz, 'İşlemler', counts[2], AppColors.success),
          _tab(3, Icons.settings_outlined, 'Sistem', counts[3],
              AppColors.accent),
        ],
      ),
    );
  }

  Widget _tab(int value, IconData icon, String label, int count, Color color) {
    final active = filter == value;
    final fg = active ? Colors.white : AppColors.textSecondary;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? Colors.white : color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text('$count',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color:
                            active ? Colors.white : AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportantCard extends StatelessWidget {
  final AppNotification item;
  final bool unread;
  final VoidCallback onTap;

  const _ImportantCard({
    required this.item,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text('Önemli',
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.message,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(relativeTime(item.when),
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Row(
            children: [
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotifGroup extends StatelessWidget {
  final List<AppNotification> items;

  const _NotifGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _NotifRow(item: items[i]),
            if (i != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final AppNotification item;

  const _NotifRow({required this.item});

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
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(relativeTime(item.when),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Text('Bu filtrede bildirim yok.',
            style: TextStyle(color: AppColors.textSecondary)),
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
            child: const Icon(Icons.notifications_none_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Bildirim yok',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'İşlem ekledikçe, bütçe ve hedeflerin ilerledikçe bildirimler burada görünür.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const _BottomCard({required this.onOpenSettings});

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
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bildirimleri Kaçırmayın',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Önemli bildirimler için bildirimleri açmayı unutmayın.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3)),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: onOpenSettings,
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
                        Text('Ayarları Aç',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right,
                            color: Colors.white, size: 18),
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
