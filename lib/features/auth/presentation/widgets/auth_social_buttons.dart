import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';

/// Sosyal giriş butonları: Google ve Apple cihazlarda "Apple ile Giriş Yap".
///
/// Apple, üçüncü taraf girişi sunan uygulamalarda Apple ile girişi de ister;
/// butonu Apple'ın yönergesine uygun (siyah zemin, Apple logosu, eşit boyut)
/// çizeriz. Android'de yalnızca Google gösterilir.
class AuthSocialButtons extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  const AuthSocialButtons({
    super.key,
    required this.onGoogle,
    required this.onApple,
  });

  static bool get _showApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            semanticLabel: 'Google ile devam et',
            onTap: onGoogle,
            child: const Icon(
              Icons.g_mobiledata,
              size: 36,
              color: Color(0xFF4285F4),
            ),
          ),
        ),
        if (_showApple) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _SocialButton(
              semanticLabel: 'Apple ile giriş yap',
              onTap: onApple,
              background: dark ? Colors.white : Colors.black,
              child: Icon(
                Icons.apple,
                size: 28,
                color: dark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;
  final Color? background;

  const _SocialButton({
    required this.child,
    required this.onTap,
    required this.semanticLabel,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: background ?? Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: background == null
                  ? Border.all(color: AppColors.border)
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
