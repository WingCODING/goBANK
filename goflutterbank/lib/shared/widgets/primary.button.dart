import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';

/// Variantes visuais do [PrimaryButton].
enum PrimaryButtonVariant { primary, success }

/// Botão principal preenchido (CTA) do Lumo.
///
/// Altura fixa de 56, cantos [AppRadii.button], tipografia [AppText.button] e
/// brilho rosado ([AppShadows.primary]) na variante primary. Mostra um spinner
/// branco quando [isLoading] e aplica um leve "scale" no toque.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expanded = true,
    this.variant = PrimaryButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;
  final PrimaryButtonVariant variant;

  // Sombra neutra suave usada pela variante de sucesso.
  static const BoxShadow _successShadow =
      BoxShadow(color: Color(0x1F16181D), blurRadius: 16, offset: Offset(0, 8));

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;
    final bool isSuccess = variant == PrimaryButtonVariant.success;

    final Color base = isSuccess ? AppColors.success : AppColors.primary;
    final Color bg = disabled ? base.withValues(alpha: 0.4) : base;

    final List<BoxShadow> shadows = disabled
        ? const <BoxShadow>[]
        : <BoxShadow>[isSuccess ? _successShadow : AppShadows.primary];

    final Widget button = Container(
      width: expanded ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.button),
        boxShadow: shadows,
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: bg,
          disabledForegroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          minimumSize: expanded ? const Size.fromHeight(56) : const Size(0, 56),
          textStyle: AppText.button,
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
                  color: AppColors.onPrimary,
                ),
              )
            : Text(label),
      ),
    );

    return _PressableScale(enabled: !disabled, child: button);
  }
}

/// Aplica um leve recuo (scale 0.98) enquanto o ponteiro está pressionado.
///
/// Usa [Listener] (que não disputa a arena de gestos) para não interferir no
/// toque do [ElevatedButton] interno.
class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.enabled});

  final Widget child;
  final bool enabled;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (!widget.enabled) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
