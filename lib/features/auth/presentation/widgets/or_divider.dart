import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';

/// "veya" yazısının iki yanında ince çizgi bulunan ayırıcı.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'veya',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
