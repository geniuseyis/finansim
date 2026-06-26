import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
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
import '../widgets/phone_field.dart';

/// Giriş yöntemi: e-posta veya telefon.
enum _AuthMode { email, phone }

/// Ekran 05 — Giriş Yap. `login-screen1/2.png` tasarımının widget karşılığı.
///
/// Üstte e-posta/telefon sekmesi; sekmeye göre alanlar değişir. E-posta ile
/// giriş Firebase üzerinden çalışır; telefon ile giriş (OTP) ileride eklenecek.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.email;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mode == _AuthMode.phone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefon ile giriş yakında eklenecek.')),
      );
      return;
    }
    await ref.read(authControllerProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  void _comingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider ile giriş yakında eklenecek.')),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      title: 'Tekrar Hoş\nGeldin! 👋',
                      subtitle: 'Finansını yönetmeye devam et.',
                      illustrationAsset: 'assets/images/login_illustration.png',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AuthModeTabs(
                            mode: _mode,
                            onChanged: (m) => setState(() => _mode = m),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_mode == _AuthMode.email)
                            AuthTextField(
                              controller: _emailController,
                              icon: Icons.mail_outline,
                              label: 'E-posta Adresi',
                              hint: 'E-posta adresinizi girin',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            )
                          else
                            PhoneField(
                              controller: _phoneController,
                              hint: 'Telefon Numaranız',
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
                            onApple: () => _comingSoon('Apple'),
                            onOther: () => _comingSoon('Bu yöntem'),
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
        ],
      ),
    );
  }
}

/// E-posta / Telefon sekme anahtarı (Login'e özel).
class _AuthModeTabs extends StatelessWidget {
  final _AuthMode mode;
  final ValueChanged<_AuthMode> onChanged;

  const _AuthModeTabs({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _tab(_AuthMode.email, Icons.mail_outline, 'E-posta ile'),
          _tab(_AuthMode.phone, Icons.phone_outlined, 'Telefon ile'),
        ],
      ),
    );
  }

  Widget _tab(_AuthMode value, IconData icon, String label) {
    final isActive = mode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
