import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import 'app_routes.dart';

/// Uygulamanın yönlendiricisini (router) sağlayan Riverpod provider'ı.
///
/// `authStateProvider`'ı izler; oturum durumu değişince `redirect` yeniden
/// çalışır ve kullanıcı uygun ekrana otomatik yönlendirilir. Böylece giriş
/// yapınca dashboard'a, çıkınca login'e gitmek için elle navigasyon gerekmez.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      // Oturum durumu henüz yükleniyorsa yönlendirme yapma (titreme olmasın).
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final location = state.matchedLocation;
      final isAuthRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgotPassword;

      // Giriş yapılmamış ve korumalı bir sayfadaysa → login'e gönder.
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;

      // Giriş yapılmış ama hâlâ auth ekranındaysa → dashboard'a gönder.
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;

      return null;
    },
    routes: [
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
    ],
  );
});
