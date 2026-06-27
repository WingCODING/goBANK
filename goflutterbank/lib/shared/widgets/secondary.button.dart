import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';

/// Botão secundário (contornado) do Lumo.
///
/// Fundo [AppColors.surface], borda de 1px [AppColors.border], texto 16/700 em
/// [AppColors.textPrimary], altura fixa de 56 e largura total. Mostra um spinner
/// quando [isLoading] e desabilita o toque.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: _labelStyle,
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Text(label),
      ),
    );
  }
}
