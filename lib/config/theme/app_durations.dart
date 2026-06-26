/// Animasyon süresi token'ları.
///
/// Tasarım dili: yumuşak, ~250ms geçişler. Tüm animasyonlar bu sabitleri
/// kullanır; böylece uygulama genelinde tutarlı bir ritim oluşur.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}
