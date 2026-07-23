import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../providers/settings_providers.dart';

/// Ekran 24 — Ayarlar.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
  }

  static String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.light => 'Açık',
        ThemeMode.dark => 'Koyu',
        ThemeMode.system => 'Sistem Varsayılanı',
      };

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final current = ref.read(themeModeProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('Tema Seç',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final m in ThemeMode.values)
              ListTile(
                leading: Icon(switch (m) {
                  ThemeMode.light => Icons.light_mode_outlined,
                  ThemeMode.dark => Icons.dark_mode_outlined,
                  ThemeMode.system => Icons.brightness_auto_outlined,
                }),
                title: Text(_themeLabel(m)),
                trailing: current == m
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).set(m);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final current = ref.read(currencyProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('Para Birimi Seç',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final e in supportedCurrencies.entries)
              ListTile(
                leading: Text(e.value.$2,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                title: Text('${e.key} - ${e.value.$1}'),
                trailing: current == e.key
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(currencyProvider.notifier).set(e.key);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final email = user?.email ?? '';
    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (email.contains('@') ? email.split('@').first : 'Kullanıcı');
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);

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
          } else if (i == 4) {
            context.push(AppRoutes.profile);
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
              _ProfileCard(
                name: name,
                email: email,
                onTap: () => context.push(AppRoutes.profile),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Section(
                title: 'Hesap Ayarları',
                tiles: [
                  _SettingTile(
                    icon: Icons.person_outline,
                    color: AppColors.primary,
                    title: 'Profil Bilgileri',
                    subtitle: 'Kişisel bilgilerinizi görüntüleyin ve düzenleyin',
                    onTap: () => context.push(AppRoutes.profile),
                  ),
                  _SettingTile(
                    icon: Icons.lock_outline,
                    color: AppColors.success,
                    title: 'Güvenlik',
                    subtitle: 'Şifre, biyometrik giriş ve güvenlik ayarları',
                    onTap: () => context.push(AppRoutes.biometric),
                  ),
                  _SettingTile(
                    icon: Icons.shield_outlined,
                    color: AppColors.warning,
                    title: 'Gizlilik',
                    subtitle: 'Hesap gizliliği ve veri kullanım tercihleri',
                    onTap: () => _soon(context),
                  ),
                  _SettingTile(
                    icon: Icons.notifications_outlined,
                    color: AppColors.accent,
                    title: 'Bildirim Ayarları',
                    subtitle: 'Bildirim tercihlerinizi yönetin',
                    onTap: () => context.push(AppRoutes.notifications),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _Section(
                title: 'Uygulama Ayarları',
                tiles: [
                  _SettingTile(
                    icon: Icons.palette_outlined,
                    color: AppColors.primary,
                    title: 'Tema',
                    subtitle: 'Açık, koyu veya sistem temasını seçin',
                    trailing: _themeLabel(themeMode),
                    onTap: () => _pickTheme(context, ref),
                  ),
                  _SettingTile(
                    icon: Icons.currency_lira,
                    color: AppColors.success,
                    title: 'Para Birimi',
                    subtitle: 'Varsayılan para birimini seçin',
                    trailing:
                        '$currency - ${supportedCurrencies[currency]?.$1 ?? ''}',
                    onTap: () => _pickCurrency(context, ref),
                  ),
                  _SettingTile(
                    icon: Icons.language,
                    color: AppColors.warning,
                    title: 'Dil',
                    subtitle: 'Uygulama dilini seçin',
                    trailing: 'Türkçe',
                    onTap: () => _soon(context),
                  ),
                  _SettingTile(
                    icon: Icons.dashboard_customize_outlined,
                    color: AppColors.accent,
                    title: 'Ana Sayfa Düzeni',
                    subtitle: 'Ana sayfada gösterilecek bileşenleri düzenleyin',
                    onTap: () => _soon(context),
                  ),
                  _SettingTile(
                    icon: Icons.grid_view_rounded,
                    color: AppColors.primary,
                    title: 'Widget Ayarları',
                    subtitle: 'Widget görünüm ve veri tercihleri',
                    onTap: () => _soon(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _Section(
                title: 'Destek & Hakkında',
                tiles: [
                  _SettingTile(
                    icon: Icons.chat_bubble_outline,
                    color: AppColors.success,
                    title: 'Yardım Merkezi',
                    subtitle: 'Sık sorulan sorular ve kullanım kılavuzu',
                    onTap: () => _soon(context),
                  ),
                  _SettingTile(
                    icon: Icons.headset_mic_outlined,
                    color: AppColors.warning,
                    title: 'Bize Ulaşın',
                    subtitle: 'Destek ekibimizle iletişime geçin',
                    onTap: () => _soon(context),
                  ),
                  _SettingTile(
                    icon: Icons.info_outline,
                    color: AppColors.accent,
                    title: 'Hakkında',
                    subtitle: 'Uygulama bilgileri ve sürüm detayları',
                    onTap: () => _soon(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _LogoutButton(
                onTap: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppBackButton(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ayarlar',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Uygulama tercihlerinizi yönetin',
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

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.primary.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
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
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_outline,
                          size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Finansım Premium',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Başlık + tek bir beyaz kart içinde ayar satırları.
class _Section extends StatelessWidget {
  final String title;
  final List<_SettingTile> tiles;

  const _Section({required this.title, required this.tiles});

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
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i != tiles.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Yeniden kullanılabilir ayar satırı.
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(trailing!,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
              ),
            ],
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.error.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: AppColors.error),
          SizedBox(width: AppSpacing.xs),
          Text('Çıkış Yap',
              style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ],
      ),
    );
  }
}
