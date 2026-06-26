import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/brand_logo.dart';

/// Ekran 01 — Açılış (Splash / Welcome).
///
/// `splash.png` tasarımının Flutter widget'larıyla pixel-perfect yeniden
/// üretimidir (PNG arka plan olarak kullanılmaz). Degrade, organik bloblar,
/// ₺ paralar, mor küre ve ışıltılar vektörel; 3B cüzdan ise opsiyonel asset
/// (`assets/images/splash_wallet.png`) olarak yerleştirilir.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final textTheme = Theme.of(context).textTheme;
    const onGradient = Colors.white;
    final onGradientSoft = Colors.white.withValues(alpha: 0.85);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D8BFF), AppColors.primary, Color(0xFF5B4BE0)],
          ),
        ),
        child: Stack(
          children: [
            _SplashScene(size: size),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 3),
                    Center(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: size.width * 0.46,
                        height: size.width * 0.46,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => BrandLogo(
                          size: size.width * 0.46,
                          showSparkle: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Finansım',
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium?.copyWith(
                        color: onGradient,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Akıllı Harcama Takip\nUygulaması',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: onGradientSoft,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(flex: 4),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: onGradient,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () => context.go(AppRoutes.onboarding),
                      child: const Text('Başla'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Zaten hesabın var mı?',
                          style: textTheme.bodyMedium?.copyWith(
                            color: onGradientSoft,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: const Text(
                            'Giriş Yap',
                            style: TextStyle(
                              color: onGradient,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

/// Splash arka plan sahnesi: organik bloblar, ₺ paralar, mor küre, ışıltılar
/// ve (varsa) 3B cüzdan illüstrasyonu. Tüm konumlar [Align] ile oranlıdır.
class _SplashScene extends StatelessWidget {
  final Size size;

  const _SplashScene({required this.size});

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    return Stack(
      children: [
        // Organik açık bloblar.
        _blob(const Alignment(-1.1, -0.85), w * 0.7, 0.10),
        _blob(const Alignment(1.2, -0.7), w * 0.55, 0.08),
        _blob(const Alignment(1.0, 0.55), w * 0.8, 0.07),
        _blob(const Alignment(-1.1, 0.95), w * 0.6, 0.06),
        // Mor küre.
        Align(
          alignment: const Alignment(-0.78, 0.18),
          child: _Sphere(size: w * 0.14),
        ),
        // İnce beyaz halka.
        Align(
          alignment: const Alignment(-0.1, 0.45),
          child: _Ring(size: w * 0.12),
        ),
        // ₺ paralar.
        Align(
          alignment: const Alignment(-0.72, 0.36),
          child: _Coin(size: w * 0.16, angle: -0.25),
        ),
        Align(
          alignment: const Alignment(0.7, 0.22),
          child: _Coin(size: w * 0.13, angle: 0.2),
        ),
        // Işıltılar.
        _sparkle(const Alignment(0.0, -0.78), w * 0.06),
        _sparkle(const Alignment(0.55, 0.34), w * 0.05),
        _sparkle(const Alignment(-0.55, 0.62), w * 0.045),
        // 3B cüzdan (opsiyonel asset). Dosya yoksa sessizce atlanır.
        Align(
          alignment: const Alignment(0.78, 0.42),
          child: SizedBox(
            width: w * 0.42,
            child: Image.asset(
              'assets/images/splash_wallet.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob(Alignment alignment, double size, double opacity) {
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
        color: Colors.white.withValues(alpha: 0.75),
      ),
    );
  }
}

/// Mor degrade küre (dekoratif).
class _Sphere extends StatelessWidget {
  final double size;

  const _Sphere({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA78BFA), AppColors.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

/// İnce beyaz halka (dekoratif).
class _Ring extends StatelessWidget {
  final double size;

  const _Ring({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
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
              color: Colors.black.withValues(alpha: 0.18),
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
