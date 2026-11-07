import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_radius.dart';

/// Tüm ikincil ekranlarda tutarlı bir "geri" butonu.
///
/// Geri gidilecek bir sayfa varsa [context.pop] ile döner. Sekmeden açılan
/// kök ekranlarda (geri yığını boşken) buton gizlenir; yerini aynı boyutta
/// boşluk tutar, böylece başlık hizası bozulmaz. Dokunma alanı 44 pt'dir.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.canPop()) return const SizedBox.square(dimension: 44);
    return Semantics(
      button: true,
      label: 'Geri',
      excludeSemantics: true,
      child: InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
      ),
    );
  }
}
