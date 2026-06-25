import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan sabit renkler.
///
/// Tüm renkler tek yerde toplanır; böylece marka rengi değişince yalnızca
/// burayı güncelleriz (DRY). Sınıf örneklenemez, sadece statik erişim sağlar.
class AppColors {
  AppColors._();

  /// Ana marka rengi — tema "seed" rengi olarak kullanılır.
  static const Color seed = Color(0xFF2E7D32);

  /// Gelir tutarlarını vurgulamak için kullanılan yeşil.
  static const Color income = Color(0xFF2E7D32);

  /// Gider tutarlarını vurgulamak için kullanılan kırmızı.
  static const Color expense = Color(0xFFC62828);

  /// Bütçe uyarılarında kullanılan turuncu.
  static const Color warning = Color(0xFFF9A825);
}
