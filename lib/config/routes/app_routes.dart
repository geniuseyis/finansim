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
  static const String statistics = '/statistics';
  static const String transactions = '/transactions';
  static const String budget = '/budget';
  static const String goals = '/goals';
  static const String categories = '/categories';
  static const String searchFilter = '/search-filter';
  static const String notifications = '/notifications';
  static const String exchangeRates = '/exchange-rates';
  static const String recurring = '/recurring';
  static const String ocr = '/ocr';
  static const String aiAdvisor = '/ai-advisor';
  static const String settings = '/settings';
  static const String profile = '/profile';
}
