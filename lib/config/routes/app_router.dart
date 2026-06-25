import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import 'app_routes.dart';

/// Uygulamanın yönlendiricisini (router) sağlayan Riverpod provider'ı.
///
/// Router'ı bir provider içine koymak, ileride kimlik doğrulama durumuna
/// göre yönlendirme (redirect) yapabilmemiz için gereklidir; çünkü router
/// o zaman auth provider'larını dinleyebilir.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
