import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_spacing.dart';

/// Ekran 01 — Açılış (Splash / Welcome) — tam ekran tasarım görseli versiyonu.
///
/// `splash-screen.png` tasarımı tam ekran gösterilir; gömülü "Başla" ve
/// "Giriş Yap" butonlarının üstüne görünmez dokunma alanları yerleştirilir.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // Gömülü butonların üzerine denk gelen dokunma alanı yükseklikleri.
  static const double _primaryHit = 64;
  static const double _secondaryHit = 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash-screen.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // "Başla" butonunun üstündeki dokunma alanı.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(AppRoutes.onboarding),
                    child: const SizedBox(
                      width: double.infinity,
                      height: _primaryHit,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // "Giriş Yap" yazısının üstündeki dokunma alanı.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go(AppRoutes.login),
                  child: const SizedBox(
                    width: double.infinity,
                    height: _secondaryHit,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
