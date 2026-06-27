import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/constants/hive_boxes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Flutter motorunun, runApp'ten önce async işlem yapabilmemiz için hazır
  // olduğundan emin oluruz.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i, flutterfire'ın ürettiği platforma özel ayarlarla başlatırız.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive'ı (yerel/offline veritabanı) başlatıp işlem kutusunu açarız.
  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.transactions);
  await Hive.openBox(HiveBoxes.budgets);
  await Hive.openBox(HiveBoxes.recurring);

  runApp(
    // ProviderScope, Riverpod'un tüm provider'ları sakladığı köktür.
    const ProviderScope(child: FinanceApp()),
  );
}

/// Uygulamanın kök widget'ı.
///
/// `ConsumerWidget`, Riverpod provider'larını okuyabilen bir widget'tır.
/// Router'ı provider'dan okuyup `MaterialApp.router`'a veririz.
class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'AI Destekli Finans',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Cihazın açık/koyu moduna uyar
      routerConfig: router,
    );
  }
}
