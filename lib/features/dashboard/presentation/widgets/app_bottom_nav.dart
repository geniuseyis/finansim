import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';

/// Ortada yüzen "+" FAB içeren floating alt navigasyon çubuğu.
///
/// Sekmeler sayfa yığınına yeni sayfa eklemez, bölümler arasında geçiş yapar
/// (`context.go`); böylece sekmeler arasında gezinmek geri yığınını
/// şişirmez. Ekranlar yalnızca hangi sekmede olduklarını bildirir; ikincil
/// ekranlar `currentIndex: -1` verir.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final VoidCallback? onAdd;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.onAdd,
  });

  static const _tabRoutes = {
    0: AppRoutes.dashboard,
    1: AppRoutes.transactions,
    3: AppRoutes.budget,
    4: AppRoutes.profile,
  };

  void _select(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    if (onTap != null) return onTap!(index);
    if (index == currentIndex) return;
    final route = _tabRoutes[index];
    if (route != null) context.go(route);
  }

  void _add(BuildContext context) {
    HapticFeedback.lightImpact();
    if (onAdd != null) return onAdd!();
    context.push(AppRoutes.addTransaction);
  }

  @override
  Widget build(BuildContext context) {
    // Ana ekran çubuğu (home indicator) olan cihazlarda çubuğun altında kalmasın.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, bottomInset > 16 ? bottomInset : 16),
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Ana Sayfa',
            active: currentIndex == 0,
            onTap: () => _select(context, 0),
          ),
          _NavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'İşlemler',
            active: currentIndex == 1,
            onTap: () => _select(context, 1),
          ),
          _CenterFab(onTap: () => _add(context)),
          _NavItem(
            icon: Icons.pie_chart_outline,
            activeIcon: Icons.pie_chart_rounded,
            label: 'Bütçe',
            active: currentIndex == 3,
            onTap: () => _select(context, 3),
          ),
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: 'Profil',
            active: currentIndex == 4,
            onTap: () => _select(context, 4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? activeIcon : icon, color: color, size: 24),
              const SizedBox(height: 2),
              // Büyük yazı tipinde çubuk taşmasın: etiket tek satır ve
              // sınırlı ölçekte kalır, sekme simgesi asıl göstergedir.
              MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.2,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -8),
          child: Semantics(
            button: true,
            label: 'İşlem ekle',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
