import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';

/// Campo de texto padrão do Lumo: rótulo opcional acima, ícone de prefixo
/// opcional e toggle de visibilidade quando [obscurable].
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.obscurable = false,
    this.filled = false,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.onSubmitted,
    this.textInputAction,
  });

  final String? label;
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final bool obscurable;
  final bool filled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: widget.controller,
      obscureText: widget.obscurable && _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      onFieldSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: widget.hint,
        fillColor: widget.filled ? AppColors.surfaceAlt : AppColors.surface,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: AppColors.iconMuted)
            : null,
        suffixIcon: widget.obscurable
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.iconMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label!, style: AppText.label),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
