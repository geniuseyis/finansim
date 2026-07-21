import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_radius.dart';

/// Tüm ikincil ekranlarda tutarlı bir "geri" butonu.
///
/// Geri gidilecek bir sayfa varsa [context.pop] ile döner; yoksa (ör. sekme
/// üzerinden gelinmişse) ana sayfaya yönlendirir.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.dashboard),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
    );
  }
}
