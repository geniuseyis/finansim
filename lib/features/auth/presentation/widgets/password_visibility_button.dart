import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Şifre alanlarında metni göster/gizle düğmesi.
class PasswordVisibilityButton extends StatelessWidget {
  final bool obscure;
  final VoidCallback onTap;

  const PasswordVisibilityButton({
    super.key,
    required this.obscure,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
      ),
      onPressed: onTap,
    );
  }
}
