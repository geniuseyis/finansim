import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/app_lock_screen.dart';
import '../providers/settings_providers.dart';

/// Uygulamanın tamamını saran kilit ve gizlilik katmanı.
///
/// - Kilit açıksa uygulama açılışında ve arka planda [relockAfter] süresinden
///   uzun kaldıktan sonra [AppLockScreen] içeriğin önüne gelir.
/// - Uygulama değiştiricide (app switcher) bakiyeler görünmesin diye uygulama
///   etkin değilken içerik marka ekranıyla örtülür.
class AppLockGate extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  static const relockAfter = Duration(seconds: 30);

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _locked = true;
  bool _obscured = false;
  DateTime? _backgroundedAt;

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (!_obscured) setState(() => _obscured = true);
      case AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
        if (!_obscured) setState(() => _obscured = true);
      case AppLifecycleState.resumed:
        final away = _backgroundedAt;
        _backgroundedAt = null;
        setState(() {
          _obscured = false;
          if (away != null &&
              DateTime.now().difference(away) > AppLockGate.relockAfter) {
            _locked = true;
          }
        });
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kilidi az önce açan (ve bu sırada kimliğini doğrulayan) kullanıcıyı
    // hemen kilitleme.
    ref.listen(appLockProvider, (previous, enabled) {
      if (enabled && previous == false) setState(() => _locked = false);
    });
    // Şifreyle yeni giriş yapan kullanıcıya ikinci kez kilit gösterme. Soğuk
    // açılışta oturum "yükleniyor"dan doğrudan kullanıcıya geçer; yalnızca
    // gerçekten çıkış yapılmış durumdan gelen girişler bu koşula uyar.
    ref.listen(authStateProvider, (previous, next) {
      final wasSignedOut =
          previous != null && !previous.isLoading && previous.value == null;
      if (wasSignedOut && next.value != null) {
        setState(() => _locked = false);
      }
    });

    final lockEnabled = ref.watch(appLockProvider);
    final signedIn = ref.watch(currentUidProvider) != null;
    final showLock = lockEnabled && signedIn && _locked;

    return Stack(
      children: [
        widget.child,
        if (showLock)
          Positioned.fill(
            child: AppLockScreen(
              onUnlocked: () => setState(() => _locked = false),
              onUsePassword: () {
                setState(() => _locked = false);
                ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          )
        else if (_obscured && signedIn)
          const Positioned.fill(child: _PrivacyCover()),
      ],
    );
  }
}

class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          width: 96,
          height: 96,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => const Icon(
            Icons.account_balance_wallet_rounded,
            size: 72,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
