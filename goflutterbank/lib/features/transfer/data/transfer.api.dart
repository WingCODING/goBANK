import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goflutterbank/core/api/api.exception.dart';

/// Resposta do `POST /api/transfer`.
@immutable
class TransferResult {
  const TransferResult({
    required this.transferId,
    required this.status,
    required this.amount,
    this.newSenderBalance,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) => TransferResult(
        transferId: json['transferId'].toString(),
        status: json['status'].toString(),
        amount: (json['amount'] as num).toDouble(),
        newSenderBalance: json['newSenderBalance'] == null
            ? null
            : (json['newSenderBalance'] as num).toDouble(),
      );

  final String transferId;
  final String status;
  final double amount;
  final double? newSenderBalance;
}

/// Transferências contra o serviço bancário (Java).
class TransferApi {
  TransferApi(this._dio);

  final Dio _dio;

  /// `POST /api/transfer` → confirma a transferência e devolve o novo saldo.
  Future<TransferResult> transfer({
    required String recipientCpf,
    required double amount,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/transfer',
        data: {'recipientCpf': recipientCpf, 'amount': amount},
      );
      return TransferResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}
