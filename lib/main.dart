import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_colors.dart';
import 'config/theme/app_theme.dart';
import 'core/services/secure_local_store.dart';
import 'core/utils/formatters.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/settings/presentation/widgets/app_lock_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Flutter motorunun, runApp'ten önce async işlem yapabilmemiz için hazır
  // olduğundan emin oluruz.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i, flutterfire'ın ürettiği platforma özel ayarlarla başlatırız.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check: yalnızca gerçek uygulamadan gelen isteklerin backend'e ulaşmasını
  // sağlar. Release'de Play Integrity, geliştirmede debug sağlayıcısı kullanılır.
  // Web'de reCAPTCHA anahtarı gerektiğinden şimdilik atlanır.
  if (!kIsWeb) {
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kReleaseMode
            ? AndroidPlayIntegrityProvider()
            : AndroidDebugProvider(),
      );
    } catch (_) {
      // App Check henüz Console'da yapılandırılmadıysa uygulama yine de açılır.
    }
  }

  // Hive'ı başlatıp ayarlar kutusunu açarız. Finans verisi kutuları şifreli ve
  // hesaba özeldir; oturum açılınca SecureLocalStore tarafından açılır.
  await SecureLocalStore.init();

  runApp(
    // ProviderScope, Riverpod'un tüm provider'ları sakladığı köktür.
    const ProviderScope(child: FinanceApp()),
  );
}

/// Uygulamanın kök widget'ı.
///
/// Tema modunu ve para birimini provider'lardan okur; sistem modunda cihazın
/// açık/koyu değişimini dinlemek için [WidgetsBindingObserver] kullanır.
class FinanceApp extends ConsumerStatefulWidget {
  const FinanceApp({super.key});

  @override
  ConsumerState<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends ConsumerState<FinanceApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Sistem teması değişince (system modundaysak) yeniden çiz.
    if (ref.read(themeModeProvider) == ThemeMode.system) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final mode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);

    // Aktif parlaklığı çöz ve özel renk token'larına uygula.
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final effective = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
    AppColors.setBrightness(effective);
    Formatters.setCurrencySymbol(supportedCurrencies[currency]?.$2 ?? '₺');

    return MaterialApp.router(
      title: 'Finansım',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: router,
      builder: (context, child) =>
          AppLockGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
