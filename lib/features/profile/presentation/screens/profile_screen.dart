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
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
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

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NameSheet(initial: current),
    );
    if (name == null || name.trim().isEmpty || name.trim() == current) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .updateDisplayName(name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Adın güncellendi.' : 'Ad güncellenemedi.')),
    );
  }

  static String _themeLabel(ThemeMode m) => switch (m) {
    ThemeMode.light => 'Açık',
    ThemeMode.dark => 'Koyu',
    ThemeMode.system => 'Sistem',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final email = user?.email ?? '';
    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (email.contains('@') ? email.split('@').first : 'Kullanıcı');

    final fs = ref.watch(financeSummaryProvider).value;
    final goals = ref.watch(goalsOverviewProvider).value;
    final budget = ref.watch(budgetOverviewProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final now = DateTime.now();
    var monthlySaving = 0.0;
    if (fs != null) {
      for (final t in fs.all) {
        if (t.date.year == now.year && t.date.month == now.month) {
          monthlySaving += t.type == TransactionType.income
              ? t.amount
              : -t.amount;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(currentIndex: 4),
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
                balance: fs?.balance ?? 0,
                monthlySaving: monthlySaving,
                goalPercent: goals?.overallPercent ?? 0,
                onTap: () => context.push(AppRoutes.settings),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                'Hesap Özeti',
                action: 'Detayları Gör',
                onAction: () => context.push(AppRoutes.statistics),
              ),
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
                onPersonal: () => _editName(context, ref, name),
                onSecurity: () => context.push(AppRoutes.security),
                onSettings: () => context.push(AppRoutes.settings),
                themeLabel: _themeLabel(themeMode),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader('Başarımlarım'),
              const SizedBox(height: AppSpacing.sm),
              _AchievementsRow(
                items: [
                  _Achievement(
                    Icons.account_balance_wallet_outlined,
                    AppColors.primary,
                    'İlk Adım',
                    'İlk işlemini ekle',
                    unlocked: (fs?.count ?? 0) > 0,
                  ),
                  _Achievement(
                    Icons.track_changes,
                    AppColors.warning,
                    'Planlayıcı',
                    'İlk bütçeni oluştur',
                    unlocked: budget != null && !budget.isEmpty,
                  ),
                  _Achievement(
                    Icons.shield_outlined,
                    AppColors.success,
                    'Tasarrufçu',
                    'Bir ayı artıda kapat',
                    unlocked: monthlySaving > 0,
                  ),
                  _Achievement(
                    Icons.emoji_events_outlined,
                    AppColors.accent,
                    'Hedef Avcısı',
                    'Bir birikim hedefini tamamla',
                    unlocked: (goals?.completedCount ?? 0) > 0,
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
              Text(
                'Profil',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hesap bilgilerinizi görüntüleyin ve yönetin',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
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
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 40,
                    ),
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
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
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
                _stat(
                  Icons.account_balance_wallet_outlined,
                  AppColors.primary,
                  'Toplam Bakiye',
                  Formatters.currency(balance),
                ),
                _divider(),
                _stat(
                  Icons.trending_up,
                  AppColors.success,
                  'Aylık Tasarruf',
                  Formatters.currency(monthlySaving),
                ),
                _divider(),
                _stat(
                  Icons.track_changes,
                  AppColors.accent,
                  'Hedef Tamamlama',
                  '%$goalPercent',
                ),
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
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
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
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  action!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.primary,
                ),
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
            _box(
              Icons.credit_card,
              AppColors.primary,
              'Toplam Gelir',
              Formatters.currency(income),
              inc.$1,
              inc.$2,
            ),
            _divider(),
            _box(
              Icons.swap_vert,
              AppColors.error,
              'Toplam Gider',
              Formatters.currency(expense),
              exp.$1,
              exp.$2,
            ),
            _divider(),
            _box(
              Icons.pie_chart_outline,
              AppColors.warning,
              'Net Değer',
              Formatters.currency(net),
              nc.$1,
              nc.$2,
            ),
            _divider(),
            _box(
              Icons.flag_outlined,
              AppColors.accent,
              'Aktif Hedef',
              '$activeGoals',
              '',
              AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.md);

  Widget _box(
    IconData icon,
    Color color,
    String title,
    String value,
    String change,
    Color changeColor,
  ) {
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
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 2),
          if (change.isNotEmpty)
            Text(
              change,
              style: TextStyle(
                fontSize: 11,
                color: changeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  final VoidCallback onPersonal;
  final VoidCallback onSecurity;
  final VoidCallback onSettings;
  final String themeLabel;

  const _AccountMenu({
    required this.onPersonal,
    required this.onSecurity,
    required this.onSettings,
    required this.themeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          _MenuRow(
            Icons.person_outline,
            AppColors.primary,
            'Kişisel Bilgilerim',
            'Görünen adını düzenle',
            onPersonal,
          ),
          const Divider(height: 1),
          _MenuRow(
            Icons.vpn_key_outlined,
            AppColors.accent,
            'Güvenlik ve Gizlilik',
            'Uygulama kilidi, şifre, hesap silme',
            onSecurity,
          ),
          const Divider(height: 1),
          _MenuRow(
            Icons.settings_outlined,
            AppColors.warning,
            'Ayarlar',
            'Tema ve para birimi',
            onSettings,
            trailing: _Pill(themeLabel),
          ),
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

  const _MenuRow(
    this.icon,
    this.color,
    this.title,
    this.subtitle,
    this.onTap, {
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              trailing!,
            ],
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
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
          Text(
            'Çıkış Yap',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
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
  final bool unlocked;

  const _Achievement(
    this.icon,
    this.color,
    this.title,
    this.desc, {
    required this.unlocked,
  });
}

/// Gerçek verilerden hesaplanan başarımlar; kazanılmayanlar kilitli görünür.
class _AchievementsRow extends StatelessWidget {
  final List<_Achievement> items;

  const _AchievementsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) => _card(items[i]),
      ),
    );
  }

  Widget _card(_Achievement a) {
    final color = a.unlocked ? a.color : AppColors.textSecondary;
    return Semantics(
      label: '${a.title}: ${a.unlocked ? 'kazanıldı' : 'kilitli'}. ${a.desc}',
      excludeSemantics: true,
      child: Container(
        width: 132,
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
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.icon, color: color, size: 26),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: a.unlocked
                          ? AppColors.success
                          : AppColors.textSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: Icon(
                      a.unlocked ? Icons.check : Icons.lock,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              a.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              a.desc,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              a.unlocked ? 'Kazanıldı' : 'Kilitli',
              style: TextStyle(
                color: a.unlocked ? AppColors.success : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameSheet extends StatefulWidget {
  final String initial;
  const _NameSheet({required this.initial});

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Kişisel Bilgilerim',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.pop(context, v),
            decoration: const InputDecoration(labelText: 'Ad Soyad'),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => Navigator.pop(context, _controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
