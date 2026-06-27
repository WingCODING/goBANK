import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';

/// Container branco com cantos arredondados e sombra suave,
/// usado para agrupar campos de formulário e blocos de conteúdo.
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: const [AppShadows.card],
      ),
      child: child,
    );
  }
}
