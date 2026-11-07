import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

/// Ayarların saklandığı Hive kutusu.
final settingsBoxProvider = Provider<Box>((ref) => Hive.box(HiveBoxes.settings));

const _kThemeKey = 'themeMode';
const _kCurrencyKey = 'currency';

/// Desteklenen para birimleri: kod → (etiket, sembol).
const supportedCurrencies = <String, (String, String)>{
  'TRY': ('Türk Lirası', '₺'),
  'USD': ('ABD Doları', '\$'),
  'EUR': ('Euro', '€'),
  'GBP': ('İngiliz Sterlini', '£'),
};

/// Seçili temayı (açık/koyu/sistem) tutar ve Hive'a kalıcı yazar.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = ref.watch(settingsBoxProvider);
    final raw = box.get(_kThemeKey) as String?;
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    await ref.read(settingsBoxProvider).put(_kThemeKey, mode.name);
    state = mode;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

/// Seçili para birimi kodunu tutar ve Hive'a kalıcı yazar.
class CurrencyController extends Notifier<String> {
  @override
  String build() {
    final box = ref.watch(settingsBoxProvider);
    final code = box.get(_kCurrencyKey) as String?;
    return supportedCurrencies.containsKey(code) ? code! : 'TRY';
  }

  Future<void> set(String code) async {
    if (!supportedCurrencies.containsKey(code)) return;
    await ref.read(settingsBoxProvider).put(_kCurrencyKey, code);
    state = code;
  }
}

final currencyProvider =
    NotifierProvider<CurrencyController, String>(CurrencyController.new);

const _kAppLockKey = 'appLock';

/// Biyometrik uygulama kilidi açık mı? Ayarlar kutusunda saklanır.
class AppLockController extends Notifier<bool> {
  @override
  bool build() {
    final box = ref.watch(settingsBoxProvider);
    return box.get(_kAppLockKey) as bool? ?? false;
  }

  Future<void> set(bool enabled) async {
    await ref.read(settingsBoxProvider).put(_kAppLockKey, enabled);
    state = enabled;
  }
}

final appLockProvider =
    NotifierProvider<AppLockController, bool>(AppLockController.new);
