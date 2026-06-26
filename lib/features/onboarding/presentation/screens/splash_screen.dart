import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/brand_logo.dart';

/// Ekran 01 — Açılış (Splash / Welcome).
///
/// Mavi-indigo degrade zemin, arka planda bozuk para ve ışıltı süslemeleri;
/// ortada marka logosu + ad + slogan; altta "Başla" ve "Giriş Yap". Tasarım
/// dosyası #01 ile hizalıdır.
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B82F6), AppColors.primary, Color(0xFF4F46E5)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _SplashDecorations()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 3),
                    const Center(child: BrandLogo()),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Finansım',
                          style: textTheme.displaySmall?.copyWith(
                            color: onGradient,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.warning,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Akıllı Harcama & Birikim Takip Uygulaması',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: onGradientSoft,
                      ),
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
                          style: TextButton.styleFrom(
                            foregroundColor: onGradient,
                          ),
                          child: const Text('Giriş Yap'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arka plan süslemeleri: yumuşak ışık daireleri, bozuk paralar ve ışıltılar.
///
/// `Align` ile oranlı yerleştirildiği için her ekran boyutunda dengeli durur.
class _SplashDecorations extends StatelessWidget {
  const _SplashDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Yumuşak ışık daireleri (bokeh).
        _bokeh(const Alignment(-0.9, -0.75), 130, 0.08),
        _bokeh(const Alignment(1.15, -0.35), 170, 0.06),
        _bokeh(const Alignment(-1.05, 0.45), 110, 0.07),
        _bokeh(const Alignment(1.1, 0.85), 150, 0.05),
        // Bozuk paralar.
        const Align(
          alignment: Alignment(0.82, -0.62),
          child: _Coin(size: 46, angle: -0.2),
        ),
        const Align(
          alignment: Alignment(-0.82, -0.32),
          child: _Coin(size: 32, angle: 0.3),
        ),
        const Align(
          alignment: Alignment(0.86, 0.18),
          child: _Coin(size: 54, angle: 0.15),
        ),
        const Align(
          alignment: Alignment(-0.85, 0.5),
          child: _Coin(size: 36, angle: -0.25),
        ),
        // Işıltılar.
        _sparkle(const Alignment(-0.45, -0.55), 18),
        _sparkle(const Alignment(0.4, -0.2), 14),
        _sparkle(const Alignment(0.55, 0.4), 20),
      ],
    );
  }

  Widget _bokeh(Alignment alignment, double size, double opacity) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }

  Widget _sparkle(Alignment alignment, double size) {
    return Align(
      alignment: alignment,
      child: Icon(
        Icons.auto_awesome,
        size: size,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}

/// Altın renkli bozuk para rozeti (₺).
class _Coin extends StatelessWidget {
  final double size;
  final double angle;

  const _Coin({required this.size, this.angle = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '₺',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
