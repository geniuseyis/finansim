import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Auth ekranlarının altındaki dekoratif mor degrade dalga.
class AuthBottomWave extends StatelessWidget {
  const AuthBottomWave({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.accent.withValues(alpha: 0.15),
                AppColors.accent.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
