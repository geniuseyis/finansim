import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/biometric_login_screen.dart';
import '../../features/ai_advisor/presentation/screens/ai_advisor_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/currency/presentation/screens/exchange_rates_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/ocr/presentation/screens/receipt_scanner_screen.dart';
import '../../features/recurring/presentation/screens/recurring_payments_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/search_filter_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import 'app_routes.dart';

/// Uygulamanın yönlendiricisini (router) sağlayan Riverpod provider'ı.
///
/// `authStateProvider`'ı izler; oturum durumu değişince `redirect` yeniden
/// çalışır ve kullanıcı uygun ekrana otomatik yönlendirilir. Böylece giriş
/// yapınca dashboard'a, çıkınca login'e gitmek için elle navigasyon gerekmez.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  // Giriş yapılmadan da erişilebilen (herkese açık) rotalar.
  const publicRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
  };

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      // Oturum durumu henüz yükleniyorsa yönlendirme yapma (titreme olmasın).
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // Giriş yapılmamış ve korumalı bir sayfadaysa → açılış ekranına gönder.
      if (!isLoggedIn && !isPublicRoute) return AppRoutes.splash;

      // Giriş yapılmış ama hâlâ herkese açık ekrandaysa → dashboard'a gönder.
      if (isLoggedIn && isPublicRoute) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.biometric,
        builder: (context, state) => const BiometricLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        // `extra` ile düzenlenecek işlem geçilirse düzenleme modu, yoksa ekleme.
        builder: (context, state) => AddEditTransactionScreen(
          existing: state.extra as AppTransaction?,
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionDetail,
        builder: (context, state) => TransactionDetailScreen(
          transaction: state.extra as AppTransaction,
        ),
      ),
      GoRoute(
        path: AppRoutes.statistics,
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.budget,
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: AppRoutes.goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.searchFilter,
        builder: (context, state) => const SearchFilterScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.exchangeRates,
        builder: (context, state) => const ExchangeRatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.recurring,
        builder: (context, state) => const RecurringPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ocr,
        builder: (context, state) => const ReceiptScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiAdvisor,
        builder: (context, state) => const AiAdvisorScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
