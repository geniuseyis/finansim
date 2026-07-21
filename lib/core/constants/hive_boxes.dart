/// Hive veritabanı kutularının (box) isimlerini tek merkezde tutar.
///
/// Box isimlerini string olarak elle yazmak yerine buradan kullanırız;
/// yazım hatası riskini azaltır ve isim değişince tek yer güncellenir.
class HiveBoxes {
  HiveBoxes._();

  static const String transactions = 'transactions';

  /// Kategori bazlı aylık bütçe limitleri (anahtar: kategori adı, değer: limit).
  static const String budgets = 'budgets';

  /// Tekrarlayan ödemeler (abonelikler, faturalar).
  static const String recurring = 'recurring';

  /// Birikim hedefleri.
  static const String goals = 'goals';
}
