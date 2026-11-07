import 'package:intl/intl.dart';

/// Para ve tarih biçimlendirme için yeniden kullanılabilir yardımcılar.
///
/// Biçimlendirmeyi tek yerde toplamak, tüm uygulamada tutarlı görünüm sağlar
/// (DRY). Sayı sembolleri intl içinde statik geldiği için ek locale yükleme
/// gerekmez; tarih için locale'den bağımsız sayısal format kullanırız.
class Formatters {
  Formatters._();

  /// Aktif para birimi sembolü. Ayarlardan değişince güncellenir.
  /// Not: yalnızca görüntüleme sembolünü değiştirir, tutarları çevirmez.
  static String _symbol = '₺';

  static void setCurrencySymbol(String symbol) => _symbol = symbol;

  /// Tutarı aktif para birimi biçiminde döndürür (ör. "₺1.250,00").
  static String currency(double amount) => NumberFormat.currency(
        locale: 'tr_TR',
        symbol: _symbol,
        decimalDigits: 2,
      ).format(amount);

  static final NumberFormat _amount = NumberFormat('#,##0.00', 'tr_TR');

  /// Sembolsüz tutar biçimi (ör. "1.250,00"). Para birimi ayrı eklenir.
  static String amount(double value) => _amount.format(value);

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
  /// "7 Kas" biçiminde kısa tarih.
  static String shortDate(DateTime date) =>
      '${date.day} ${_trMonths[date.month - 1].substring(0, 3)}';

  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  /// Yüzdeyi Türkçe biçimde döndürür (ör. "%12,45"). İşaret ayrı eklenir.
  static String percent(double value) =>
      '%${value.abs().toStringAsFixed(2).replaceAll('.', ',')}';
}
