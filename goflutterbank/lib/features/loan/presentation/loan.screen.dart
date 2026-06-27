import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/core/utils/currency.dart';
import 'package:goflutterbank/features/auth/providers/auth.controller.dart';
import 'package:goflutterbank/features/loan/providers/loan.providers.dart';
import 'package:goflutterbank/shared/widgets/form.card.dart';
import 'package:goflutterbank/shared/widgets/primary.button.dart';
import 'package:goflutterbank/shared/widgets/success.sheet.dart';

/// Tela 07 — Empréstimo (raiz de aba, sem voltar, sem bottomNavigationBar).
class LoanScreen extends ConsumerStatefulWidget {
  const LoanScreen({super.key});

  @override
  ConsumerState<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends ConsumerState<LoanScreen> {
  static const List<int> _options = [1000, 3000, 5000, 10000];

  // Juros mensais e prazo usados na simulação.
  static const double _monthlyRate = 0.029;
  static const int _installments = 12;

  int _selected = _options.indexOf(5000);
  bool _loading = false;

  /// Formata um inteiro com separador de milhar pt-BR, sem casas decimais.
  /// thousands(5000) -> '5.000', thousands(10000) -> '10.000'.
  String _thousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// PMT = PV * i / (1 - (1 + i)^-n).
  double _monthlyPayment(int principal) {
    final pv = principal.toDouble();
    final i = _monthlyRate;
    final n = _installments;
    return pv * i / (1 - math.pow(1 + i, -n));
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    final principal = _options[_selected];
    try {
      // O tomador é o usuário autenticado: o loan-service lê o CPF do JWT.
      final result = await ref.read(loanApiProvider).request(
            principal: principal.toString(),
            interestRate: _monthlyRate.toString(),
          );
      // o desembolso credita a conta — atualiza o saldo exibido na Home
      await ref.read(authControllerProvider.notifier).refreshProfile();

      if (!mounted) return;

      final valueLabel = 'R\$ ${_thousands(principal)}';
      final approved = result.status.toUpperCase() == 'DISBURSED';
      await showSuccessSheet(
        context,
        title: approved ? 'Empréstimo aprovado!' : 'Solicitação recebida!',
        message: approved
            ? '$valueLabel creditado na sua conta.'
            : 'Seu empréstimo de $valueLabel está em processamento.',
        onDone: () => context.go('/home'),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = _options[_selected];
    final pmt = _monthlyPayment(selectedValue);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text('Empréstimo', style: AppText.titleScreen),
              const SizedBox(height: 24),

              // Bloco do valor selecionado.
              Column(
                children: [
                  const Text(
                    'Quanto você precisa?',
                    textAlign: TextAlign.center,
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Text(
                      'R\$ ${_thousands(selectedValue)}',
                      key: ValueKey<int>(selectedValue),
                      textAlign: TextAlign.center,
                      style: AppText.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Crédito pré-aprovado · até R\$ 10.000',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chips de seleção de valor.
              Row(
                children: [
                  for (var i = 0; i < _options.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _AmountChip(
                        label: 'R\$ ${_thousands(_options[i])}',
                        selected: i == _selected,
                        onTap: () => setState(() => _selected = i),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Simulação.
              FormCard(
                child: Column(
                  children: [
                    const _SimRow(
                      left: 'Taxa de juros',
                      right: '2,9% / mês',
                    ),
                    const _SimDivider(),
                    _SimRow(
                      left: 'Parcelas',
                      right: '12x de ${formatBRL(pmt)}',
                    ),
                    const _SimDivider(),
                    const _SimRow(
                      left: '1ª parcela',
                      right: 'em 30 dias',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                label: 'Solicitar empréstimo',
                isLoading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Sujeito a análise de crédito · CET 38,4% ao ano',
                      style: AppText.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip de seleção de valor com transição de cor.
class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Linha da tabela de simulação.
class _SimRow extends StatelessWidget {
  const _SimRow({required this.left, required this.right});

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(left, style: AppText.caption.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          right,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SimDivider extends StatelessWidget {
  const _SimDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 24, thickness: 1, color: AppColors.border);
  }
}
