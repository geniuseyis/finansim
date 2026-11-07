import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/services/secure_local_store.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/app_lock_screen.dart';
import '../providers/settings_providers.dart';

/// Güvenlik ve Gizlilik: biyometrik uygulama kilidi, şifre sıfırlama ve
/// hesabı silme. Verilerin nerede ve nasıl tutulduğu da burada anlatılır.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _busy = false;

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _toggleLock(bool enable) async {
    final biometric = ref.read(biometricServiceProvider);
    if (enable && !await biometric.isAvailable()) {
      _message('Cihazında kayıtlı bir Face ID / parmak izi bulunamadı.');
      return;
    }
    // Açarken de kapatırken de kimlik doğrulanır; telefonu eline alan biri
    // kilidi sessizce kapatamaz.
    final ok = await biometric.authenticate(
      reason: enable
          ? 'Uygulama kilidini açmak için kimliğini doğrula'
          : 'Uygulama kilidini kapatmak için kimliğini doğrula',
    );
    if (!ok) return;
    await ref.read(appLockProvider.notifier).set(enable);
  }

  Future<void> _sendReset(String email) async {
    final sent = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(email);
    if (!mounted) return;
    _message(sent
        ? 'Şifre sıfırlama bağlantısı $email adresine gönderildi.'
        : 'Bağlantı gönderilemedi. Tekrar dene.');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hesabını sil',
      message: 'Hesabın ve bu cihazdaki tüm işlem, bütçe, hedef ve ödeme '
          'kayıtların kalıcı olarak silinecek. Bu işlem geri alınamaz.',
      confirmLabel: 'Hesabı Sil',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    // Firebase silme için yakın tarihli giriş ister; şifreli hesapta şifre
    // sorulur, Google/Apple hesabında sağlayıcı kendi doğrulamasını açar.
    String? password;
    final user = ref.read(authStateProvider).value;
    if (user?.hasPassword ?? false) {
      password = await _askPassword();
      if (password == null || !mounted) return;
    }

    setState(() => _busy = true);
    final deleted = await ref
        .read(authControllerProvider.notifier)
        .deleteAccount(password: password);
    if (deleted) {
      await SecureLocalStore.wipeCurrentUser();
      await ref.read(appLockProvider.notifier).set(false);
      return; // Oturum kapandı; yönlendirici giriş ekranına götürür.
    }
    if (!mounted) return;
    setState(() => _busy = false);
    final error = ref.read(authControllerProvider).error;
    _message(error?.toString() ?? 'Hesap silinemedi.');
  }

  Future<String?> _askPassword() => showAdaptiveDialog<String>(
        context: context,
        builder: (_) => const _PasswordDialog(),
      );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final lockEnabled = ref.watch(appLockProvider);
    final method = ref.watch(biometricMethodProvider).value ?? 'Biyometri';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Güvenlik ve Gizlilik',
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Uygulama Kilidi'),
            AppCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile.adaptive(
                value: lockEnabled,
                onChanged: _busy ? null : _toggleLock,
                secondary: const Icon(Icons.lock_outline),
                title: Text('$method ile kilitle'),
                subtitle: const Text(
                  'Uygulama açılırken ve 30 saniyeden uzun arka planda '
                  'kaldıktan sonra kimlik doğrulaması ister.',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Şifre'),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                enabled: !_busy && user?.email.isNotEmpty == true,
                leading: const Icon(Icons.key_outlined),
                title: const Text('Şifre sıfırlama bağlantısı gönder'),
                subtitle: Text(user?.email ?? ''),
                onTap: () => _sendReset(user!.email),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Verilerin'),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'İşlemlerin, bütçelerin ve hedeflerin yalnızca bu cihazda, '
                'AES-256 ile şifrelenmiş olarak saklanır; şifreleme anahtarı '
                'cihazın güvenli anahtar deposundadır. Yapay zeka analizine '
                'yalnızca 0-100 arası skorlar gönderilir, işlem ayrıntıların '
                'cihazdan çıkmaz.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary, height: 1.45),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                enabled: !_busy,
                leading: const Icon(Icons.delete_forever_outlined,
                    color: AppColors.error),
                title: const Text(
                  'Hesabımı Sil',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: _busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _deleteAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Hesap silmeden önce şifre soran pencere. Denetleyiciyi kendi yaşam
/// döngüsünde tutar; kapanış animasyonu bitmeden yok edilmez.
class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Şifreni doğrula'),
      content: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Material(
          type: MaterialType.transparency,
          child: TextField(
            controller: _controller,
            autofocus: true,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.pop(context, v),
            decoration: const InputDecoration(hintText: 'Şifre'),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Devam', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}
