import 'package:flutter/material.dart';

import '../../config/theme/app_radius.dart';
import '../../config/theme/app_spacing.dart';

/// Design System'in temel kart bileşeni.
///
/// Premium fintech görünümü için çok hafif "soft shadow" ve cömert köşe
/// yuvarlaklığı taşır. Opsiyonel [gradient] ile vurgulu kartlar (ör. bakiye
/// kartı), [onTap] ile dokunulabilir kartlar üretilir. Tek bileşen, çok varyant
/// (DRY) — tüm ekranlar bunu kullanır.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AppRadius.card);

    final decoration = BoxDecoration(
      color: gradient == null ? (color ?? theme.colorScheme.surface) : null,
      gradient: gradient,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );

    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: decoration,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: content,
              ),
            ),
    );
  }
}
