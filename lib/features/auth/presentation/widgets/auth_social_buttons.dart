import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';

/// Sosyal giriş butonları satırı (Google · Apple · diğer).
class AuthSocialButtons extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onOther;

  const AuthSocialButtons({
    super.key,
    required this.onGoogle,
    required this.onApple,
    required this.onOther,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            onTap: onGoogle,
            child: const Icon(
              Icons.g_mobiledata,
              size: 36,
              color: Color(0xFF4285F4),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SocialButton(
            onTap: onApple,
            child: const Icon(Icons.apple, size: 28, color: Colors.black),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SocialButton(
            onTap: onOther,
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Text(
                'R',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SocialButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}
