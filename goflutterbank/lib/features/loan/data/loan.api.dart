import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goflutterbank/core/api/api.exception.dart';

/// Resposta do `POST /loans` (loan-service Go).
@immutable
class LoanResult {
  const LoanResult({required this.id, required this.status});

  factory LoanResult.fromJson(Map<String, dynamic> json) => LoanResult(
        id: json['id'].toString(),
        status: json['status'].toString(),
      );

  final String id;
  final String status;
}

/// Solicitações de empréstimo contra o loan-service (Go).
class LoanApi {
  LoanApi(this._dio);

  final Dio _dio;

  /// `POST /loans` → cria a solicitação de empréstimo.
  ///
  /// O tomador NÃO é enviado: o loan-service o deriva do JWT (claim `cpf`), que o
  /// AuthInterceptor já anexa. `principal` e `interestRate` vão como String (o
  /// backend Go espera decimais em texto).
  Future<LoanResult> request({
    required String principal,
    required String interestRate,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/loans',
        data: {
          'principal': principal,
          'interestRate': interestRate,
        },
      );
      return LoanResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}
