import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_durations.dart';
import '../../../../config/theme/app_spacing.dart';

/// Ekran 02-03-04 — Onboarding — tam ekran tasarım görselleri versiyonu.
///
/// `Onboarding1/2/3.png` tasarımları bir [PageView] içinde tam ekran gösterilir;
/// gömülü "Atla" ve "İleri/Başlayalım" butonlarının üstüne görünmez dokunma
/// alanları yerleştirilir. Kaydırma PageView ile çalışır.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageAssets = [
    'assets/images/Onboarding1.png',
    'assets/images/Onboarding2.png',
    'assets/images/Onboarding3.png',
  ];

  // Gömülü butonların üzerine denk gelen dokunma alanı yüksekliği.
  static const double _buttonHit = 64;

  final _controller = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _pageAssets.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_isLastPage) {
      context.go(AppRoutes.login);
    } else {
      _controller.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pageAssets.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) =>
                Image.asset(_pageAssets[index], fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                // "Atla" yazısının üstündeki dokunma alanı (sağ üst).
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(AppRoutes.login),
                    child: const SizedBox(width: 96, height: 48),
                  ),
                ),
                const Spacer(),
                // "İleri / Başlayalım" butonunun üstündeki dokunma alanı.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onNext,
                    child: const SizedBox(
                      width: double.infinity,
                      height: _buttonHit,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
