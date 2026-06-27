import 'package:dio/dio.dart';

/// Erro normalizado da API: mensagem pronta para exibir + status HTTP + erros por campo.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;
  final Map<String, String>? fieldErrors;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Converte `DioException` em `ApiException`, extraindo a mensagem do backend.
///
/// O bank (Java) responde erros como:
///   - `{"error": "Email ou senha inválidos"}`
///   - `{"errors": {"email": "deve ser um e-mail", ...}}`  (validação)
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(err.copyWith(error: _map(err)));
  }

  ApiException _map(DioException err) {
    final response = err.response;
    final status = response?.statusCode;
    final data = response?.data;

    if (data is Map) {
      if (data['error'] is String) {
        return ApiException(data['error'] as String, statusCode: status);
      }
      if (data['errors'] is Map) {
        final fields = (data['errors'] as Map)
            .map((k, v) => MapEntry(k.toString(), v.toString()));
        final first = fields.values.isNotEmpty ? fields.values.first : 'Dados inválidos';
        return ApiException(first, statusCode: status, fieldErrors: fields);
      }
    }
    return ApiException(_fallback(err), statusCode: status);
  }

  String _fallback(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão esgotado. Tente novamente.';
      case DioExceptionType.connectionError:
        return 'Não foi possível conectar ao servidor.';
      default:
        return 'Algo deu errado. Tente novamente.';
    }
  }
}

/// Desembrulha o `ApiException` de um `DioException` lançado pelo ErrorInterceptor.
ApiException toApiException(DioException e) {
  final err = e.error;
  if (err is ApiException) return err;
  return ApiException('Falha de comunicação com o servidor.', statusCode: e.response?.statusCode);
}
