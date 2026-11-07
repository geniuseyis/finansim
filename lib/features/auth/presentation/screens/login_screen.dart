import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
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

/// Ekran 05 — Giriş Yap. `login-screen1/2.png` tasarımının widget karşılığı.
///
/// E-posta/şifre, Google ve (Apple cihazlarda) Apple ile giriş Firebase
/// üzerinden çalışır. Alanlar Anahtar Zinciri otomatik doldurmayı destekler.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
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
                        title: 'Tekrar Hoş\nGeldin! 👋',
                        subtitle: 'Finansını yönetmeye devam et.',
                        illustrationAsset:
                            'assets/images/login_illustration.png',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              controller: _emailController,
                              icon: Icons.mail_outline,
                              label: 'E-posta Adresi',
                              hint: 'E-posta adresinizi girin',
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                              validator: Validators.email,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              label: 'Şifre',
                              hint: 'Şifrenizi girin',
                              obscure: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _signIn(),
                              autofillHints: const [AutofillHints.password],
                              suffix: PasswordVisibilityButton(
                                obscure: _obscurePassword,
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: Validators.password,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    context.push(AppRoutes.forgotPassword),
                                child: const Text('Şifremi Unuttum?'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FilledButton(
                              onPressed: isLoading ? null : _signIn,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Giriş Yap'),
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
                                  'Hesabın yok mu?',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.register),
                                  child: const Text('Kayıt Ol'),
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
