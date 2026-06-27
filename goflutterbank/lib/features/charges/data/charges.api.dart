import 'package:dio/dio.dart';
import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/features/charges/data/charge.models.dart';

/// Cobranças (payment-requests) contra o serviço bancário (Java).
class ChargesApi {
  ChargesApi(this._dio);

  final Dio _dio;

  /// `GET /api/payment-requests/incoming` → cobranças recebidas (você é o pagador).
  Future<List<Charge>> incoming() => _list('/api/payment-requests/incoming');

  /// `GET /api/payment-requests/outgoing` → cobranças enviadas (você é o cobrador).
  Future<List<Charge>> outgoing() => _list('/api/payment-requests/outgoing');

  Future<List<Charge>> _list(String path) async {
    try {
      final res = await _dio.get<List<dynamic>>(path);
      final data = res.data ?? const <dynamic>[];
      return data
          .map((e) => Charge.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// `POST /api/payment-requests` → cria uma cobrança para `payerCpf`.
  Future<Charge> create({
    required String payerCpf,
    required double amount,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/payment-requests',
        data: {'payerCpf': payerCpf, 'amount': amount},
      );
      return Charge.fromJson(res.data!);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// `POST /api/payment-requests/{id}/approve` → aprova/paga a cobrança.
  Future<Charge> approve(String id) => _action(id, 'approve');

  /// `POST /api/payment-requests/{id}/reject` → recusa a cobrança.
  Future<Charge> reject(String id) => _action(id, 'reject');

  Future<Charge> _action(String id, String action) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/payment-requests/$id/$action',
      );
      return Charge.fromJson(res.data!);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}
