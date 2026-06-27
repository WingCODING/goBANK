import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';

/// Estados possíveis de uma cobrança.
enum ChargeBadge { pending, approved, rejected }

/// Pílula colorida que indica o status de uma cobrança.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ChargeBadge status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      ChargeBadge.pending => (AppColors.warningBg, AppColors.warningText, 'Pendente'),
      ChargeBadge.approved => (AppColors.successBg, AppColors.success, 'Aprovada'),
      ChargeBadge.rejected => (const Color(0xFFFEE2E2), AppColors.danger, 'Recusada'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
