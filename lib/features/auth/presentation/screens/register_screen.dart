import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_card.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_bottom_wave.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/or_divider.dart';
import '../widgets/password_visibility_button.dart';

/// Ekran 06 — Kayıt Ol. `register` tasarımının widget karşılığı.
///
/// Ad Soyad, e-posta, şifre ve şifre tekrarı alanları + koşul onayı.
/// Kayıt Firebase e-posta/şifre ile yapılır; ad, hesabın görünen adı olur.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devam etmek için koşulları kabul etmelisin.'),
        ),
      );
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          const AuthBottomWave(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'Hesabını\nOluştur 👋',
                        subtitle: 'Finansını kolayca yönetmeye hemen başla.',
                        illustrationAsset:
                            'assets/images/register_illustration.png',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              controller: _nameController,
                              icon: Icons.person_outline,
                              label: 'Ad Soyad',
                              hint: 'Adınızı ve soyadınızı girin',
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.name],
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Ad soyad gerekli.'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              controller: _emailController,
                              icon: Icons.mail_outline,
                              label: 'E-posta Adresi',
                              hint: 'E-posta adresinizi girin',
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              validator: Validators.email,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              label: 'Şifre',
                              hint: 'En az 8 karakter, harf ve rakam',
                              obscure: _obscurePassword,
                              autofillHints: const [AutofillHints.newPassword],
                              suffix: PasswordVisibilityButton(
                                obscure: _obscurePassword,
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: Validators.newPassword,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              controller: _confirmController,
                              icon: Icons.lock_outline,
                              label: 'Şifre Tekrar',
                              hint: 'Şifrenizi tekrar girin',
                              obscure: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _register(),
                              suffix: PasswordVisibilityButton(
                                obscure: _obscureConfirm,
                                onTap: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              validator: (value) =>
                                  value != _passwordController.text
                                  ? 'Şifreler eşleşmiyor.'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TermsCheckbox(
                              value: _acceptedTerms,
                              onChanged: (v) =>
                                  setState(() => _acceptedTerms = v ?? false),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FilledButton(
                              onPressed: isLoading ? null : _register,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Kayıt Ol'),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const OrDivider(),
                            const SizedBox(height: AppSpacing.lg),
                            AuthSocialButtons(
                              onGoogle: () => ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithGoogle(),
                              onApple: () => ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithApple(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Zaten hesabın var mı?',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('Giriş Yap'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kullanım koşulları onay kutusu.
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(value: value, onChanged: onChanged),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text.rich(
              TextSpan(
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                children: const [
                  TextSpan(
                    text:
                        'Kullanım koşullarını ve gizlilik politikasını '
                        'okudum, ',
                  ),
                  TextSpan(
                    text: 'kabul ediyorum.',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
