import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';

/// Auth ekranlarındaki etiketli giriş alanı.
///
/// Tasarıma uygun olarak: sol ikon + üstte kalıcı etiket + altta ipucu metni
/// (placeholder), opsiyonel sağ aksiyon (göz aç/kapa). Login ve Register
/// ekranlarının tamamı bu tek bileşeni kullanır (DRY).
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  /// iOS Anahtar Zinciri / Android otomatik doldurma ipuçları.
  final Iterable<String>? autofillHints;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  textCapitalization: textCapitalization,
                  inputFormatters: inputFormatters,
                  autofillHints: autofillHints,
                  validator: validator,
                  onFieldSubmitted: onFieldSubmitted,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    hintText: hint,
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}
