import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/utils/currency.dart';
import 'package:goflutterbank/shared/models/activity.item.dart';

/// Linha de uma transação/atividade (Home recent activity, extratos, etc).
class TransactionRow extends StatelessWidget {
  final ActivityItem item;

  const TransactionRow({super.key, required this.item});

  Color get _avatarBg {
    switch (item.type) {
      case ActivityType.received:
        return const Color(0xFFD1FAE5);
      case ActivityType.sent:
      case ActivityType.payment:
        return const Color(0xFFF1F2F4);
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case ActivityType.received:
        return AppColors.success;
      case ActivityType.sent:
      case ActivityType.payment:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (item.type) {
      case ActivityType.received:
        return Icons.south_west;
      case ActivityType.sent:
        return Icons.north_east;
      case ActivityType.payment:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = item.amount >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _avatarBg,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 20, color: _iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatBRL(item.amount, signed: true),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isPositive ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
