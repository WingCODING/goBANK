import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/shared/widgets/primary.button.dart';

/// Exibe um bottom sheet de confirmação (sucesso ou destaque da marca).
Future<void> showSuccessSheet(
  BuildContext context, {
  required String title,
  String? message,
  String doneLabel = 'Concluído',
  VoidCallback? onDone,
  bool success = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: false,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewInsets.bottom +
          MediaQuery.of(ctx).padding.bottom;

      return Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: success
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 32,
                color: success ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.titleM,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: doneLabel,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onDone?.call();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
