import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/core/utils/currency.dart';
import 'package:goflutterbank/core/utils/formatters.dart';
import 'package:goflutterbank/features/charges/providers/charges.controller.dart';
import 'package:goflutterbank/shared/widgets/amount.field.dart';
import 'package:goflutterbank/shared/widgets/app.field.dart';
import 'package:goflutterbank/shared/widgets/form.card.dart';
import 'package:goflutterbank/shared/widgets/primary.button.dart';
import 'package:goflutterbank/shared/widgets/screen.appbar.dart';
import 'package:goflutterbank/shared/widgets/success.sheet.dart';

/// Tela 06 — Nova cobrança. Rota PUSHED em '/charges/new' (tem voltar).
/// Cria uma cobrança via Pix informando CPF do pagador e valor.
class NewChargeScreen extends ConsumerStatefulWidget {
  const NewChargeScreen({super.key});

  @override
  ConsumerState<NewChargeScreen> createState() => _NewChargeScreenState();
}

class _NewChargeScreenState extends ConsumerState<NewChargeScreen> {
  final _cpf = TextEditingController();
  final _amount = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _cpf.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final cpf = stripCpf(_cpf.text);
    final amt = brlTextToDouble(_amount.text);

    if (cpf.length != 11) {
      _showError('Informe um CPF válido com 11 dígitos.');
      return;
    }
    if (amt <= 0) {
      _showError('Informe um valor maior que zero.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(chargesControllerProvider.notifier)
          .createCharge(payerCpf: cpf, amount: amt);
      if (!mounted) return;
      await showSuccessSheet(
        context,
        title: 'Cobrança criada!',
        message: 'Cobrança de ${formatBRL(amt)} criada.',
        onDone: () => context.pop(),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: 'Nova cobrança',
                onBack: () => context.pop(),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.volunteer_activism_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Crie uma cobrança e envie via Pix para quem precisa te pagar.',
                        style: AppText.caption.copyWith(
                          color: const Color(0xFF9B2A4D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'CPF do pagador',
                      hint: '000.000.000-00',
                      icon: Icons.credit_card,
                      filled: true,
                      controller: _cpf,
                      inputFormatters: [CpfInputFormatter()],
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    AmountField(
                      label: 'Valor da cobrança',
                      controller: _amount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Cobrar',
                isLoading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
