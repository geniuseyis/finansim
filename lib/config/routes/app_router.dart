import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/presentation/screens/add_edit_transaction_screen.dart';
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
        path: AppRoutes.addTransaction,
        // `extra` ile düzenlenecek işlem geçilirse düzenleme modu, yoksa ekleme.
        builder: (context, state) => AddEditTransactionScreen(
          existing: state.extra as AppTransaction?,
        ),
      ),
    ],
  );
});
