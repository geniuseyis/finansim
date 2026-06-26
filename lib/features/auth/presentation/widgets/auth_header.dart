import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';

/// Auth ekranlarının üst bölümü: solda başlık + alt yazı, sağda illüstrasyon.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String illustrationAsset;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustrationAsset,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: Image.asset(
            illustrationAsset,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox(height: 180),
          ),
        ),
      ],
    );
  }
}
