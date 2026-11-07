import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../shared/widgets/app_card.dart';
import '../widgets/auth_bottom_wave.dart';
import '../widgets/or_divider.dart';

/// Biyometrik servisi sağlayan provider (DI).
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);

/// Ekran — Biyometrik Giriş. Oturumu açık kullanıcı için hızlı kilit açma.
///
/// Parmak izi / yüz ile doğrulama `local_auth` üzerinden yapılır; başarıda
/// dashboard'a geçilir. Alternatif olarak şifre ile giriş sunulur.
class BiometricLoginScreen extends ConsumerStatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  ConsumerState<BiometricLoginScreen> createState() =>
      _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends ConsumerState<BiometricLoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    // Ekran açılır açılmaz biyometrik istemi başlat.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final success = await ref.read(biometricServiceProvider).authenticate(
          reason: 'Finansım hesabına erişmek için kimliğini doğrula',
        );
    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama başarısız. Tekrar deneyin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          const AuthBottomWave(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.go(AppRoutes.login),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  Image.asset(
                    'assets/images/biometric_illustration.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(height: 200),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Biyometrik Giriş',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Devam etmek için parmak izinizi kullanın.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        _FingerprintScanner(
                          animation: _ringController,
                          onTap: _authenticate,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Parmağınızı sensöre yerleştirin',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified_user,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Güvenli ve şifreli bağlantı',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const OrDivider(),
                  const SizedBox(height: AppSpacing.lg),
                  _MethodTile(
                    icon: Icons.lock_outline,
                    label: 'Şifre ile Giriş Yap',
                    onTap: () => context.go(AppRoutes.login),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _MethodTile(
                    icon: Icons.face_outlined,
                    label: 'Face ID ile Giriş Yap',
                    onTap: _authenticate,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabın yok mu?',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text('Kayıt Ol'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dönen ilerleme halkası içinde parmak izi ikonu (dokunulabilir).
class _FingerprintScanner extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onTap;

  const _FingerprintScanner({required this.animation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sabit açık dış halka.
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  width: 6,
                ),
              ),
            ),
            // Dönen mavi ilerleme yayı.
            RotationTransition(
              turns: animation,
              child: const SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 6,
                  color: AppColors.primary,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            // Ortadaki parmak izi.
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 64,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alternatif giriş yöntemi satırı (ikon + etiket + chevron).
class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
