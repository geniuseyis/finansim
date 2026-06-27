import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/exchange_rate_service.dart';

final exchangeRateServiceProvider = Provider<ExchangeRateService>(
  (ref) => ExchangeRateService(),
);

/// Canlı döviz kurlarını sağlayan provider (yükleniyor/hata/veri).
/// Yenilemek için `ref.invalidate(exchangeRatesProvider)`.
final exchangeRatesProvider = FutureProvider<ExchangeData>(
  (ref) => ref.watch(exchangeRateServiceProvider).fetch(),
);
