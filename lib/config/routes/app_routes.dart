/// Uygulamadaki tüm rota yollarının (path) tek merkezden yönetildiği yer.
///
/// Yol isimlerini string olarak elle yazmak yerine buradan kullanırız;
/// böylece yazım hatası riski azalır ve yol değişince tek yer güncellenir.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String biometric = '/biometric';
  static const String addTransaction = '/add-transaction';
  static const String transactionDetail = '/transaction-detail';
}
