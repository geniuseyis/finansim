import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_durations.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';

/// Tek bir onboarding sayfasının içeriğini taşıyan veri modeli.
class _OnboardingPageData {
  final String illustration;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.illustration,
    required this.title,
    required this.description,
  });
}

const _pages = <_OnboardingPageData>[
  _OnboardingPageData(
    illustration: 'assets/images/onboarding_illustration_1.png',
    title: 'Harcamalarını Kolayca Takip Et',
    description:
        'Gelir ve giderlerini kategorilere ayır, paranın nereye gittiğini gör.',
  ),
  _OnboardingPageData(
    illustration: 'assets/images/onboarding_illustration_2.png',
    title: 'Bütçeni Planla, Hedeflerine Ulaş',
    description:
        'Bütçe oluştur, tasarruf et ve hedeflerine adım adım ilerle.',
  ),
  _OnboardingPageData(
    illustration: 'assets/images/onboarding_illustration_3.png',
    title: 'Verilerin Güvende',
    description:
        'Bankacılık seviyesinde şifreleme ile gizliliğin korunur.',
  ),
];

/// Ekran 02-03-04 — Onboarding (3 sayfalık tanıtım).
///
/// Tasarım dosyalarındaki düzen widget'larla yeniden üretilir; illüstrasyonlar
/// `assets/images/onboarding_illustration_{n}.png` dosyalarından okunur (dosya
/// yoksa geçici placeholder gösterilir).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_isLastPage) {
      _finish();
    } else {
      _controller.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.sm,
                  top: AppSpacing.xs,
                ),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Atla'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: _pages[index]),
              ),
            ),
            _PageDots(count: _pages.length, activeIndex: _currentPage),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: FilledButton(
                onPressed: _onNext,
                child: Text(_isLastPage ? 'Başlayalım' : 'İleri'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir onboarding sayfası: illüstrasyon + başlık + açıklama.
class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                data.illustration,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const _IllustrationPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

/// İllüstrasyon asset'i bulunamazsa gösterilen geçici görsel.
class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 64,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Sayfa konum göstergesi: aktif nokta geniş mavi bir pill olarak gösterilir.
class _PageDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _PageDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: AppDurations.medium,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          height: AppSpacing.xs,
          width: isActive ? AppSpacing.xl : AppSpacing.xs,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        );
      }),
    );
  }
}
