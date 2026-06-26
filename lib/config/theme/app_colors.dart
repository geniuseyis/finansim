import 'package:flutter/material.dart';

/// Renk token'ları (Design System).
///
/// Tüm renkler tek kaynaktan beslenir; bir markayı değiştirmek = tek dosya.
/// Premium fintech paleti: canlı ama kurumsal, yüksek okunabilirlik.
class AppColors {
  AppColors._();

  // --- Marka renkleri ---
  /// Ana marka rengi — canlı mavi.
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// İkincil — turkuaz (palet çipi #06B6D4 ile birebir).
  static const Color secondary = Color(0xFF06B6D4);

  /// Vurgu — mor.
  static const Color accent = Color(0xFF8B5CF6);

  // --- Anlamsal (semantic) renkler ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF8B5CF6);

  /// Gelir tutarları (yeşil) ve gider tutarları (kırmızı).
  static const Color income = success;
  static const Color expense = error;

  // --- Açık tema nötrleri ---
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // --- Koyu tema nötrleri (lacivert tonları) ---
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111A2E);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E293B);

  // --- Premium degrade (kart/başlık vurguları için) ---
  static const List<Color> primaryGradient = [
    Color(0xFF2563EB),
    Color(0xFF3B82F6),
  ];

  /// Geriye dönük uyumluluk için tema tohum rengi.
  static const Color seed = primary;
}
