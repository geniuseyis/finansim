import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografi token'ları — Poppins tabanlı.
///
/// Genel metin teması [AppTheme] içinde Poppins'e çevrilir; burada ise
/// para tutarları gibi özel/öne çıkan stilleri tanımlarız. Renk vermeyiz;
/// renk temadan (onSurface vb.) gelir, böylece dark mode otomatik çalışır.
class AppTextStyles {
  AppTextStyles._();

  /// Çok büyük para tutarı (örn. toplam bakiye kartı).
  static TextStyle get amountXLarge =>
      GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, height: 1.1);

  /// Büyük para tutarı (örn. işlem detayı).
  static TextStyle get amountLarge =>
      GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700);

  /// Bölüm başlığı (H2).
  static TextStyle get sectionTitle =>
      GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600);
}
