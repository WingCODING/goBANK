import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/core/utils/currency.dart';
import 'package:goflutterbank/core/utils/formatters.dart';
import 'package:goflutterbank/features/auth/providers/auth.controller.dart';
import 'package:goflutterbank/features/transfer/providers/transfer.providers.dart';
import 'package:goflutterbank/shared/mock/mock.data.dart';
import 'package:goflutterbank/shared/models/contact.dart';
import 'package:goflutterbank/shared/widgets/amount.field.dart';
import 'package:goflutterbank/shared/widgets/app.field.dart';
import 'package:goflutterbank/shared/widgets/avatar.dart';
import 'package:goflutterbank/shared/widgets/form.card.dart';
import 'package:goflutterbank/shared/widgets/primary.button.dart';
import 'package:goflutterbank/shared/widgets/success.sheet.dart';

/// Tela 04 — Transferir (raiz de aba, sem botão de voltar e sem bottom nav).
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _cpf = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _cpf.dispose();
    _amount.dispose();
    super.dispose();
  }

  /// Aplica a máscara de CPF a 11 dígitos brutos e preenche o campo.
  void _fillContact(Contact contact) {
    final masked = CpfInputFormatter().formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: contact.cpf),
    );
    setState(() {
      _cpf.value = masked;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final cpf = stripCpf(_cpf.text);
    final amt = brlTextToDouble(_amount.text);

    if (cpf.length != 11) {
      _showError('Informe um CPF válido (11 dígitos).');
      return;
    }
    if (amt <= 0) {
      _showError('Informe um valor maior que zero.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(transferApiProvider).transfer(recipientCpf: cpf, amount: amt);
      // atualiza o saldo exibido na Home após o débito
      await ref.read(authControllerProvider.notifier).refreshProfile();

      if (!mounted) return;
      _cpf.clear();
      _amount.clear();

      await showSuccessSheet(
        context,
        title: 'Transferência enviada!',
        message: '${formatBRL(amt)} enviados.',
        onDone: () => context.go('/home'),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final balance = user?.balance ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transferir', style: AppText.titleScreen),
              const SizedBox(height: 20),
              const Text('ENVIAR PARA', style: AppText.overline),
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kMockContacts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final contact = kMockContacts[index];
                    return _ContactChip(
                      contact: contact,
                      onTap: () => _fillContact(contact),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'CPF do destinatário',
                      hint: '000.000.000-00',
                      icon: Icons.credit_card,
                      controller: _cpf,
                      filled: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CpfInputFormatter()],
                    ),
                    const SizedBox(height: 16),
                    AmountField(label: 'Valor', controller: _amount),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.wallet_outlined,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saldo disponível: ${formatBRL(balance)}',
                          style: AppText.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Transferir',
                isLoading: _loading,
                onPressed: _loading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.contact, required this.onTap});

  final Contact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialsAvatar(initials: contact.initials, size: 56, highlight: true),
          const SizedBox(height: 8),
          Text(contact.shortName, style: AppText.caption),
        ],
      ),
    );
  }
}
