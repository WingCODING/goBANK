import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/features/auth/providers/auth.controller.dart';
import 'package:goflutterbank/shared/widgets/app.field.dart';
import 'package:goflutterbank/shared/widgets/primary.button.dart';
import 'package:goflutterbank/shared/widgets/secondary.button.dart';

/// Tela 01 — Login. Wired ao backend via [AuthController].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _email.text.trim(),
            password: _password.text,
          );
      // o redirect do go_router leva para /home automaticamente
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(authControllerProvider.select((s) => s.isSubmitting));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandLogo(),
                  const SizedBox(height: 12),
                  Text('Lumo', style: AppText.titleBrand, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Seu banco digital', style: AppText.caption, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'E-mail',
                    hint: 'voce@email.com',
                    icon: Icons.mail_outline,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null,
                  ),
                  const SizedBox(height: AppSpacing.block),
                  AppTextField(
                    label: 'Senha',
                    hint: 'Digite sua senha',
                    icon: Icons.lock_outline,
                    controller: _password,
                    obscurable: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (v) => (v == null || v.isEmpty) ? 'Informe sua senha' : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Entrar',
                    isLoading: submitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ou',
                            style: AppText.caption.copyWith(color: AppColors.textTertiary)),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    label: 'Criar conta',
                    onPressed: () => context.go('/signup'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text('Protegido com criptografia de ponta a ponta',
                          style: AppText.caption.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadii.logo),
          boxShadow: const [AppShadows.primary],
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}
