import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/finance_summary_provider.dart';

/// Değişim yüzdesini ok + renk ile döndürür.
(String, Color) _change(double pct) {
  final up = pct >= 0;
  return (
    '${up ? '↑' : '↓'} ${Formatters.percent(pct)}',
    up ? AppColors.success : AppColors.error,
  );
}

/// Ekran 23 — Profil.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final email = user?.email ?? '';
    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (email.contains('@') ? email.split('@').first : 'Kullanıcı');

    final fs = ref.watch(financeSummaryProvider).value;
    final goals = ref.watch(goalsOverviewProvider).value;
    final now = DateTime.now();
    var monthlySaving = 0.0;
    if (fs != null) {
      for (final t in fs.all) {
        if (t.date.year == now.year && t.date.month == now.month) {
          monthlySaving +=
              t.type == TransactionType.income ? t.amount : -t.amount;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onBell: () => context.push(AppRoutes.notifications)),
              const SizedBox(height: AppSpacing.lg),
              _ProfileCard(
                name: name,
                email: email,
                balance: fs?.balance ?? 0,
                monthlySaving: monthlySaving,
                goalPercent: goals?.overallPercent ?? 0,
                onTap: () => context.push(AppRoutes.settings),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader('Hesap Özeti',
                  action: 'Detayları Gör',
                  onAction: () => context.push(AppRoutes.statistics)),
              const SizedBox(height: AppSpacing.sm),
              _AccountSummaryCard(
                income: fs?.income ?? 0,
                expense: fs?.expense ?? 0,
                net: fs?.net ?? 0,
                activeGoals: goals?.active.length ?? 0,
                incomeChange: fs?.incomeChange ?? 0,
                expenseChange: fs?.expenseChange ?? 0,
                netChange: fs?.netChange ?? 0,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader('Hesap & Ayarlar'),
              const SizedBox(height: AppSpacing.sm),
              _AccountMenu(
                onPersonal: () => _soon(context),
                onBanks: () => _soon(context),
                onPayments: () => _soon(context),
                onSecurity: () => context.push(AppRoutes.security),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader('Başarımlarım',
                  action: 'Tümünü Gör', onAction: () => _soon(context)),
              const SizedBox(height: AppSpacing.sm),
              const _AchievementsCarousel(),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader('Uygulama'),
              const SizedBox(height: AppSpacing.sm),
              _AppMenu(onItem: () => context.push(AppRoutes.settings)),
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
              Text('Profil',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Hesap bilgilerinizi görüntüleyin ve yönetin',
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
  final double balance;
  final double monthlySaving;
  final int goalPercent;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.balance,
    required this.monthlySaving,
    required this.goalPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.primary.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.12),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person,
                        color: AppColors.primary, size: 40),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(Icons.photo_camera,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
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
                            fontSize: 19, fontWeight: FontWeight.w800)),
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
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              children: [
                _stat(Icons.account_balance_wallet_outlined, AppColors.primary,
                    'Toplam Bakiye', Formatters.currency(balance)),
                _divider(),
                _stat(Icons.trending_up, AppColors.success, 'Aylık Tasarruf',
                    Formatters.currency(monthlySaving)),
                _divider(),
                _stat(Icons.track_changes, AppColors.accent,
                    'Hedef Tamamlama', '%$goalPercent'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.md);

  Widget _stat(IconData icon, Color color, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader(this.title, {this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(action!,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double net;
  final int activeGoals;
  final double incomeChange;
  final double expenseChange;
  final double netChange;

  const _AccountSummaryCard({
    required this.income,
    required this.expense,
    required this.net,
    required this.activeGoals,
    required this.incomeChange,
    required this.expenseChange,
    required this.netChange,
  });

  @override
  Widget build(BuildContext context) {
    final inc = _change(incomeChange);
    final exp = _change(expenseChange);
    final nc = _change(netChange);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _box(Icons.credit_card, AppColors.primary, 'Toplam Gelir',
                Formatters.currency(income), inc.$1, inc.$2),
            _divider(),
            _box(Icons.swap_vert, AppColors.error, 'Toplam Gider',
                Formatters.currency(expense), exp.$1, exp.$2),
            _divider(),
            _box(Icons.pie_chart_outline, AppColors.warning, 'Net Değer',
                Formatters.currency(net), nc.$1, nc.$2),
            _divider(),
            _box(Icons.flag_outlined, AppColors.accent, 'Aktif Hedef',
                '$activeGoals', '', AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.md);

  Widget _box(IconData icon, Color color, String title, String value,
      String change, Color changeColor) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          if (change.isNotEmpty)
            Text(change,
                style: TextStyle(
                    fontSize: 11,
                    color: changeColor,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  final VoidCallback onPersonal;
  final VoidCallback onBanks;
  final VoidCallback onPayments;
  final VoidCallback onSecurity;

  const _AccountMenu({
    required this.onPersonal,
    required this.onBanks,
    required this.onPayments,
    required this.onSecurity,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          _MenuRow(Icons.person_outline, AppColors.primary, 'Kişisel Bilgilerim',
              'Profil bilgilerinizi görüntüleyin ve düzenleyin', onPersonal),
          const Divider(height: 1),
          _MenuRow(Icons.account_balance_outlined, AppColors.success,
              'Banka Hesaplarım', 'Bağlı hesaplarınızı yönetin', onBanks),
          const Divider(height: 1),
          _MenuRow(Icons.credit_card, AppColors.warning, 'Ödeme Yöntemlerim',
              'Kayıtlı kartlarınızı ve yöntemlerinizi yönetin', onPayments),
          const Divider(height: 1),
          _MenuRow(Icons.vpn_key_outlined, AppColors.accent, 'Güvenlik',
              'Şifre, biyometrik giriş ve güvenlik ayarları', onSecurity),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuRow(this.icon, this.color, this.title, this.subtitle, this.onTap,
      {this.trailing});

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
              trailing!,
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

class _Achievement {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final String date;

  const _Achievement(this.icon, this.color, this.title, this.desc, this.date);
}

class _AchievementsCarousel extends StatelessWidget {
  const _AchievementsCarousel();

  static const _items = [
    _Achievement(Icons.account_balance_wallet_outlined, AppColors.primary,
        'İlk Adım', 'İlk işlemini tamamladın', '10.03.2025'),
    _Achievement(Icons.shield_outlined, AppColors.success, 'Tasarrufçu',
        '₺5.000 tasarruf ettin', '15.04.2025'),
    _Achievement(Icons.track_changes, AppColors.warning, 'Planlayıcı',
        'İlk bütçeni oluşturdun', '22.04.2025'),
    _Achievement(Icons.emoji_events_outlined, AppColors.accent, 'Başarılı',
        '3 hedef tamamladın', '01.05.2025'),
    _Achievement(Icons.diamond_outlined, AppColors.primary, 'Premium',
        'Premium üye oldun', '05.05.2025'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) => _card(_items[i]),
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

  Widget _card(_Achievement a) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(a.icon, color: a.color, size: 26),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(a.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Text(a.desc,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 10, height: 1.2)),
          const Spacer(),
          Text(a.date,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _AppMenu extends StatelessWidget {
  final VoidCallback onItem;

  const _AppMenu({required this.onItem});

  @override
  Widget build(BuildContext context) {
    Widget pill(String text) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(text,
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        );

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          _MenuRow(Icons.dark_mode_outlined, AppColors.primary, 'Görünüm',
              'Uygulama temasını seçin', onItem,
              trailing: pill('Sistem Varsayılanı')),
          const Divider(height: 1),
          _MenuRow(Icons.language, AppColors.accent, 'Dil',
              'Uygulama dilini seçin', onItem, trailing: pill('Türkçe')),
          const Divider(height: 1),
          _MenuRow(Icons.info_outline, AppColors.warning, 'Hakkında',
              'Uygulama bilgileri ve sürüm detayları', onItem),
        ],
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
