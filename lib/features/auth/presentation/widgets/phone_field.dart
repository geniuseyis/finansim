import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';

/// Telefon numarası alanı: "+90" ülke kodu kutusu + numara girişi.
///
/// [label] verilirse üstte kalıcı etiket ve sol ikon ile (Register tarzı),
/// verilmezse kompakt satır olarak (Login tarzı) gösterilir.
class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String hint;

  const PhoneField({
    super.key,
    required this.controller,
    this.label,
    this.hint = 'Telefon numaranızı girin',
  });

  @override
  Widget build(BuildContext context) {
    final field = Row(
      children: [
        _CountryCode(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
            ),
            validator: (value) => (value == null || value.trim().length < 10)
                ? 'Geçerli bir numara girin.'
                : null,
          ),
        ),
      ],
    );

    if (label == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: _boxDecoration(),
        child: field,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: _boxDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.phone_iphone, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                field,
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.border),
      );
}

/// "+90 ▾" ülke kodu kutusu (şimdilik sabit).
class _CountryCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('+90', style: TextStyle(fontWeight: FontWeight.w700)),
          Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}
