import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';

/// Avatar circular com as iniciais do usuário/contato.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.highlight = false,
  });

  final String initials;
  final double size;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bg = highlight ? AppColors.primaryLight : const Color(0xFFF1F2F4);
    final fg = highlight ? AppColors.primary : AppColors.textSecondary;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.35,
          color: fg,
        ),
      ),
    );
  }
}
