import 'package:dio/dio.dart';
import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/core/api/auth.interceptor.dart';
import 'package:goflutterbank/core/config/app.config.dart';
import 'package:goflutterbank/core/storage/token.storage.dart';

/// Fábrica do cliente HTTP (Dio) já configurado para um serviço:
/// baseUrl + timeouts + JWT (AuthInterceptor) + erros normalizados (ErrorInterceptor).
Dio createDio({required String baseUrl, required TokenStorage tokenStorage}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage),
    ErrorInterceptor(),
  ]);

  return dio;
}

/// Dio para o serviço bancário (Java).
Dio createBankDio(TokenStorage tokenStorage) =>
    createDio(baseUrl: AppConfig.bankBaseUrl, tokenStorage: tokenStorage);

/// Dio para o loan-service (Go).
Dio createLoanDio(TokenStorage tokenStorage) =>
    createDio(baseUrl: AppConfig.loanBaseUrl, tokenStorage: tokenStorage);
