import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/core/utils/formatters.dart';

/// Campo de valor em reais: prefixo "R$" fixo e dígitos tratados como centavos.
/// Leia o valor com `brlTextToDouble(controller.text)`.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    this.label,
    required this.controller,
  });

  final String? label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          const Text(
            r'R$',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [BrlInputFormatter()],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                hintText: '0,00',
                hintStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (label == null) return box;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: AppText.label),
        const SizedBox(height: 8),
        box,
      ],
    );
  }
}
