import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_sizes.dart';
import '../../../../config/theme/app_spacing.dart';

/// Ekran 01 — Açılış (Splash / Welcome).
///
/// Mavi degrade zemin, ortada marka logosu + ad + slogan; altta "Başla" ve
/// mevcut kullanıcılar için "Giriş Yap" bağlantısı. Tasarım dosyası #01 ile
/// birebir hizalıdır.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const onGradient = Colors.white;
    final onGradientSoft = Colors.white.withValues(alpha: 0.85);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                const _BrandLogo(),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Finansım',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    color: onGradient,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Akıllı Harcama & Birikim Takip Uygulaması',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: onGradientSoft),
                ),
                const Spacer(flex: 4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: onGradient,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Başla'),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten hesabın var mı?',
                      style: textTheme.bodyMedium?.copyWith(
                        color: onGradientSoft,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      style: TextButton.styleFrom(foregroundColor: onGradient),
                      child: const Text('Giriş Yap'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Beyaz yuvarlak kart içinde marka ikonu (logo rozeti).
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppSizes.splashLogo,
        height: AppSizes.splashLogo,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Icon(
          Icons.insights_rounded,
          size: AppSizes.iconLg,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
