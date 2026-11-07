import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Cihazdaki biyometrik yöntemin adı ("Face ID", "Parmak izi"...).
final biometricMethodProvider = FutureProvider<String>(
  (ref) => ref.watch(biometricServiceProvider).methodName(),
);

/// Uygulama kilidi ekranı. Ayarlardan kilit açıksa, uygulama açılırken ve
/// arka planda bir süre kaldıktan sonra içeriğin önüne gelir.
///
/// Biyometrik istem ekran açılır açılmaz başlar. Kullanıcı biyometri
/// kullanamıyorsa çıkış yapıp şifresiyle yeniden girebilir.
class AppLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback onUsePassword;

  const AppLockScreen({
    super.key,
    required this.onUnlocked,
    required this.onUsePassword,
  });

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // "Hareketi Azalt" açıksa halka dönmez.
    if (MediaQuery.disableAnimationsOf(context)) {
      _ringController.stop();
    } else if (!_ringController.isAnimating) {
      _ringController.repeat();
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final success = await ref
        .read(biometricServiceProvider)
        .authenticate(reason: 'Finansım\'ın kilidini açmak için kimliğini doğrula');
    if (!mounted) return;
    if (success) {
      widget.onUnlocked();
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final method = ref.watch(biometricMethodProvider).value ?? 'Biyometri';
    final isFace = method == 'Face ID' || method == 'Yüz tanıma';

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
                  const SizedBox(height: AppSpacing.lg),
                  Image.asset(
                    'assets/images/biometric_illustration.png',
                    height: 200,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => const SizedBox(height: 200),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Finansım Kilitli',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Devam etmek için $method kullan.',
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
                        _BiometricScanner(
                          animation: _ringController,
                          icon: isFace ? Icons.face_outlined : Icons.fingerprint,
                          label: '$method ile kilidi aç',
                          onTap: _authenticate,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          _failed
                              ? 'Doğrulanamadı. Tekrar denemek için dokun.'
                              : 'Kilidi açmak için dokun',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: _failed
                                ? AppColors.error
                                : AppColors.textSecondary,
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
                              'Verilerin cihazında şifreli',
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
                    onTap: widget.onUsePassword,
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

/// Dönen ilerleme halkası içinde biyometri ikonu (dokunulabilir).
class _BiometricScanner extends StatelessWidget {
  final Animation<double> animation;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BiometricScanner({
    required this.animation,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                ),
                child: Icon(icon, size: 64, color: AppColors.primary),
              ),
            ],
          ),
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
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
