import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/core/utils/formatters.dart';
import 'package:goflutterbank/features/auth/providers/auth.controller.dart';
import 'package:goflutterbank/shared/widgets/app.field.dart';
import 'package:goflutterbank/shared/widgets/primary.button.dart';
import 'package:goflutterbank/shared/widgets/screen.appbar.dart';

/// Tela 02 — Cadastro ("Crie sua conta"). Wired ao backend via [AuthController].
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _cpf = TextEditingController();
  final _password = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _cpf.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aceite os termos para continuar')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            cpf: stripCpf(_cpf.text),
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
    final submitting =
        ref.watch(authControllerProvider.select((s) => s.isSubmitting));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  title: 'Crie sua conta',
                  onBack: () => context.go('/login'),
                ),
                const SizedBox(height: 4),
                Text('Leva menos de 2 minutos.', style: AppText.caption),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Nome completo',
                  hint: 'Como no seu documento',
                  icon: Icons.person_outline,
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe seu nome completo'
                      : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'E-mail',
                  hint: 'voce@email.com',
                  icon: Icons.mail_outline,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Informe um e-mail válido'
                      : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'CPF',
                  hint: '000.000.000-00',
                  icon: Icons.credit_card,
                  controller: _cpf,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [CpfInputFormatter()],
                  validator: (v) => stripCpf(v ?? '').length == 11
                      ? null
                      : 'Informe um CPF válido',
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Senha',
                  hint: 'Ao menos 8 caracteres',
                  icon: Icons.lock_outline,
                  controller: _password,
                  obscurable: true,
                  onSubmitted: (_) => _submit(),
                  validator: (v) => (v == null || v.length < 8)
                      ? 'A senha deve ter ao menos 8 caracteres'
                      : null,
                ),
                const SizedBox(height: 20),
                _TermsRow(
                  value: _acceptedTerms,
                  onChanged: (v) =>
                      setState(() => _acceptedTerms = v ?? false),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Cadastrar',
                  isLoading: submitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já tem conta? ', style: AppText.caption),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Entrar', style: AppText.link),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  style: AppText.caption,
                  children: [
                    const TextSpan(text: 'Li e aceito os '),
                    TextSpan(
                      text: 'Termos de uso',
                      style: AppText.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' e a '),
                    TextSpan(
                      text: 'Política de Privacidade.',
                      style: AppText.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
