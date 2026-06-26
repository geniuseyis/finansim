import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dashboard_repository.dart';
import '../models/dashboard_view_data.dart';

/// Dashboard repository sağlayıcısı (DI). Şimdilik dummy implementasyon.
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const DummyDashboardRepository(),
);

/// Dashboard verisini asenkron yükleyen provider (yükleniyor/hata/veri).
final dashboardDataProvider = FutureProvider<DashboardViewData>(
  (ref) => ref.watch(dashboardRepositoryProvider).getDashboardData(),
);
