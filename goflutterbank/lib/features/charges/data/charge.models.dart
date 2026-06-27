import 'package:flutter/foundation.dart';

/// Status de uma cobrança (payment-request), normalizado do backend.
enum ChargeStatus { pending, approved, rejected, unknown }

/// Mapeia a string de status do backend.
///
/// `PENDING` → pending, `APPROVED`/`COMPLETED` → approved, `REJECTED` → rejected;
/// qualquer outra coisa → unknown.
ChargeStatus chargeStatusFrom(String raw) {
  switch (raw.toUpperCase().trim()) {
    case 'PENDING':
      return ChargeStatus.pending;
    case 'APPROVED':
    case 'COMPLETED':
      return ChargeStatus.approved;
    case 'REJECTED':
      return ChargeStatus.rejected;
    default:
      return ChargeStatus.unknown;
  }
}

/// Cobrança (payment-request). O backend só devolve UUIDs de conta + valor +
/// status (sem nome/CPF do pagador).
@immutable
class Charge {
  const Charge({
    required this.id,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  factory Charge.fromJson(Map<String, dynamic> json) => Charge(
        id: json['id'].toString(),
        amount: (json['amount'] as num).toDouble(),
        status: chargeStatusFrom(json['status']?.toString() ?? ''),
        createdAt: _parseDate(json['createdAt']),
      );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  final String id;
  final double amount;
  final ChargeStatus status;
  final DateTime? createdAt;
}
