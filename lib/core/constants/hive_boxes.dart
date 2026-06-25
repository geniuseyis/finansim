/// Hive veritabanı kutularının (box) isimlerini tek merkezde tutar.
///
/// Box isimlerini string olarak elle yazmak yerine buradan kullanırız;
/// yazım hatası riskini azaltır ve isim değişince tek yer güncellenir.
class HiveBoxes {
  HiveBoxes._();

  static const String transactions = 'transactions';
}
