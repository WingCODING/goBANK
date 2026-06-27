import 'package:dio/dio.dart';
import 'package:goflutterbank/core/storage/token.storage.dart';

/// Anexa o JWT (`Authorization: Bearer ...`) em toda requisição quando há token salvo.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
