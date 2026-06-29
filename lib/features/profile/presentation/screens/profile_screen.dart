import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';

/// Ekran 23 — Profil. Gerçek kullanıcı bilgisi (Firebase) + araç kısayolları.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
  }

  String _displayName(WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final name = user?.displayName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final email = user?.email;
    if (email != null && email.contains('@')) {
      final local = email.split('@').first;
      return local.isEmpty ? local : local[0].toUpperCase() + local.substring(1);
    }
    return 'Kullanıcı';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabından çıkış yapmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final name = _displayName(ref);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onAdd: () => context.push(AppRoutes.addTransaction),
        onTap: (i) {
          if (i == 0) {
            context.go(AppRoutes.dashboard);
          } else if (i == 1) {
            context.go(AppRoutes.transactions);
          } else if (i == 3) {
            context.push(AppRoutes.budget);
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Profil',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  onPressed: () => _soon(context),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _ProfileCard(
              name: name,
              email: user?.email ?? '',
              initials: _initials(name),
              onEdit: () => _soon(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _MenuCard(
              title: 'Finanslarım',
              items: [
                _MenuItem(Icons.insights, AppColors.primary, 'İstatistiklerim',
                    () => context.push(AppRoutes.statistics)),
                _MenuItem(Icons.track_changes, AppColors.accent, 'Hedeflerim',
                    () => context.push(AppRoutes.goals)),
                _MenuItem(Icons.pie_chart_outline, AppColors.success,
                    'Bütçelerim', () => context.push(AppRoutes.budget)),
                _MenuItem(Icons.event_repeat, AppColors.warning,
                    'Tekrarlayan Ödemeler',
                    () => context.push(AppRoutes.recurring)),
                _MenuItem(Icons.grid_view_rounded, AppColors.primary,
                    'Kategoriler', () => context.push(AppRoutes.categories)),
                _MenuItem(Icons.currency_exchange, AppColors.success,
                    'Döviz Kurları',
                    () => context.push(AppRoutes.exchangeRates)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _MenuCard(
              title: 'Uygulama',
              items: [
                _MenuItem(Icons.notifications_none, AppColors.warning,
                    'Bildirimler', () => context.push(AppRoutes.notifications)),
                _MenuItem(Icons.fingerprint, AppColors.accent,
                    'Biyometrik Giriş',
                    () => context.push(AppRoutes.biometric)),
                _MenuItem(Icons.settings_outlined, AppColors.textSecondary,
                    'Ayarlar', () => context.push(AppRoutes.settings)),
                _MenuItem(Icons.info_outline, AppColors.textSecondary,
                    'Hakkında', () => _soon(context)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Text('Profili Düzenle',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
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

class _MenuItem {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.color, this.title, this.onTap);
}

class _MenuCard extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                InkWell(
                  onTap: items[i].onTap,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: items[i].color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(items[i].icon,
                              color: items[i].color, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(items[i].title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                        ),
                        const Icon(Icons.chevron_right,
                            size: 20, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                if (i != items.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
