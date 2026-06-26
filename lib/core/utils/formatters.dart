import 'package:intl/intl.dart';

/// Para ve tarih biçimlendirme için yeniden kullanılabilir yardımcılar.
///
/// Biçimlendirmeyi tek yerde toplamak, tüm uygulamada tutarlı görünüm sağlar
/// (DRY). Sayı sembolleri intl içinde statik geldiği için ek locale yükleme
/// gerekmez; tarih için locale'den bağımsız sayısal format kullanırız.
class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  /// Tutarı Türk Lirası biçiminde döndürür (ör. "₺1.250,00").
  static String currency(double amount) => _currency.format(amount);

  /// Tarihi "gg.aa.yyyy" biçiminde döndürür (ör. "26.06.2026").
  static String date(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

  static const List<String> _trMonths = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  /// Tarihi "7 Mayıs 2025" biçiminde döndürür (locale yüklemesi gerekmez).
  static String longDate(DateTime date) =>
      '${date.day} ${_trMonths[date.month - 1]} ${date.year}';

  /// Saati "14:32" biçiminde döndürür.
  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  /// Yüzdeyi Türkçe biçimde döndürür (ör. "%12,45"). İşaret ayrı eklenir.
  static String percent(double value) =>
      '%${value.abs().toStringAsFixed(2).replaceAll('.', ',')}';
}
