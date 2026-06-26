import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_radius.dart';

/// "Finansım" marka logosu — yuvarlatılmış kare içinde yükselen çubuk grafik
/// ve büyüme oku, sağ üstte ışıltı (sparkle).
///
/// Vektörel çizildiği için her boyutta keskin kalır (pixel perfect). Hem açık
/// (beyaz kutu / mavi mark) hem koyu zeminlerde kullanılabilir.
class BrandLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color markColor;
  final bool showSparkle;

  const BrandLogo({
    super.key,
    this.size = 88,
    this.backgroundColor = Colors.white,
    this.markColor = AppColors.primary,
    this.showSparkle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.24),
              child: CustomPaint(painter: _LogoMarkPainter(markColor)),
            ),
          ),
          if (showSparkle)
            Positioned(
              top: -size * 0.06,
              right: -size * 0.06,
              child: Icon(
                Icons.auto_awesome,
                size: size * 0.30,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }
}

/// Logo işaretini (çubuklar + yükselen ok) çizen ressam.
class _LogoMarkPainter extends CustomPainter {
  final Color color;

  _LogoMarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Artan üç çubuk (bar chart).
    final barWidth = s * 0.18;
    final baseline = s * 0.96;
    final tops = [0.62, 0.44, 0.26]; // her çubuğun üst y oranı
    final xs = [0.06, 0.41, 0.76]; // her çubuğun sol x oranı
    for (var i = 0; i < 3; i++) {
      final left = s * xs[i];
      final top = s * tops[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, baseline - top),
          Radius.circular(barWidth / 2),
        ),
        fill,
      );
    }

    // Yükselen büyüme oku.
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final line = Path()
      ..moveTo(s * 0.10, s * 0.34)
      ..lineTo(s * 0.42, s * 0.16)
      ..lineTo(s * 0.86, s * 0.04);
    canvas.drawPath(line, stroke);

    // Ok ucu (sağ üstte).
    final tipX = s * 0.86;
    final tipY = s * 0.04;
    final arrow = Path()
      ..moveTo(s * 0.66, s * 0.06)
      ..lineTo(tipX, tipY)
      ..lineTo(s * 0.84, s * 0.26);
    canvas.drawPath(arrow, stroke);
  }

  @override
  bool shouldRepaint(_LogoMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
