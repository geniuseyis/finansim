import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';

/// Sıradan bir bildirim satırı.
class _Notif {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String time;

  const _Notif(this.title, this.description, this.icon, this.color, this.time);
}

/// Önemli bildirim (kırmızı "Önemli" rozetli, okunmamış noktalı).
class _Important {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String time;

  const _Important(this.title, this.description, this.icon, this.color,
      this.time);
}

const _important = <_Important>[
  _Important('Bütçe Uyarısı', "Yemek bütçenizin %90'ını kullandınız.",
      Icons.error_outline, AppColors.error, '5 dakika önce'),
  _Important('Fatura Hatırlatması',
      'Elektrik faturanızın son ödeme tarihi yaklaşıyor.',
      Icons.access_time, AppColors.warning, '1 saat önce'),
  _Important('Hedefe Yaklaştınız', "Yeni Araba hedefinizde %75'e ulaştınız!",
      Icons.trending_up, AppColors.error, '2 saat önce'),
];

const _today = <_Notif>[
  _Notif('Yeni İşlem Eklendi', 'Migros alışveriş işleminiz başarıyla eklendi.',
      Icons.arrow_circle_down_outlined, AppColors.success, '14:32'),
  _Notif('Para Transferi', "Mehmet Yılmaz'dan gelen transfer gerçekleşti.",
      Icons.swap_horiz, AppColors.primary, '12:18'),
  _Notif('Hedef Güncellemesi', 'Ev Peşinatı hedefinize ₺5.000 eklendi.',
      Icons.track_changes, AppColors.accent, '10:45'),
  _Notif('Haftalık Rapor Hazır',
      'Haftalık harcama raporunuz hazır. Görüntülemek için tıklayın.',
      Icons.show_chart, AppColors.success, '09:00'),
];

const _yesterday = <_Notif>[
  _Notif('Restoran Harcaması', 'Burger King harcamanız için teşekkürler.',
      Icons.restaurant_outlined, AppColors.warning, 'Dün, 19:30'),
  _Notif('Fatura Ödendi', 'İnternet faturanız başarıyla ödendi.',
      Icons.description_outlined, AppColors.accent, 'Dün, 16:45'),
  _Notif('Başarı Rozeti', 'Tasarruf uzmanı rozetini kazandınız!',
      Icons.star_outline, AppColors.warning, 'Dün, 11:20'),
];

/// Ekran 18 — Bildirimler.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0;
  Set<int> _unread = {0, 1, 2};

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
          } else if (i == 4) {
            context.push(AppRoutes.profile);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onSettings: () => context.push(AppRoutes.settings)),
              const SizedBox(height: AppSpacing.lg),
              _FilterBar(
                filter: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(
                    child: Text('Önemli Bildirimler',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _unread = {}),
                    child: const Text('Tümünü Okundu İşaretle',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < _important.length; i++) ...[
                _ImportantCard(
                  item: _important[i],
                  unread: _unread.contains(i),
                  onTap: _soon,
                ),
                if (i != _important.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.lg),
              _sectionTitle('Bugün'),
              const SizedBox(height: AppSpacing.sm),
              _NotifGroup(items: _today, onTap: _soon),
              const SizedBox(height: AppSpacing.lg),
              _sectionTitle('Dün'),
              const SizedBox(height: AppSpacing.sm),
              _NotifGroup(items: _yesterday, onTap: _soon),
              const SizedBox(height: AppSpacing.lg),
              _BottomCard(onOpenSettings: () => context.push(AppRoutes.settings)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
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
  final ValueChanged<int> onChanged;

  const _FilterBar({required this.filter, required this.onChanged});

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
          _tab(0, Icons.notifications_none, 'Tümü', 12, AppColors.primary),
          _tab(1, Icons.error_outline, 'Önemli', 4, AppColors.error),
          _tab(2, Icons.swap_horiz, 'İşlemler', 5, AppColors.success),
          _tab(3, Icons.settings_outlined, 'Sistem', 3, AppColors.accent),
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
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: 4),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: fg)),
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
                        color: active ? Colors.white : AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportantCard extends StatelessWidget {
  final _Important item;
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
                Text(item.description,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(item.time,
                    style: const TextStyle(
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
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotifGroup extends StatelessWidget {
  final List<_Notif> items;
  final VoidCallback onTap;

  const _NotifGroup({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _NotifRow(item: items[i], onTap: onTap),
            if (i != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final _Notif item;
  final VoidCallback onTap;

  const _NotifRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  Text(item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(item.time,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
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
                const Text(
                    'Önemli bildirimler için bildirimleri açmayı unutmayın.',
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
