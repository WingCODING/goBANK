import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goflutterbank/core/api/api.client.dart';
import 'package:goflutterbank/core/storage/token.storage.dart';

/// Armazenamento seguro do JWT.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// Dio do serviço bancário (Java). Reage a mudanças no tokenStorage.
final bankDioProvider = Provider<Dio>((ref) {
  final dio = createBankDio(ref.watch(tokenStorageProvider));
  ref.onDispose(dio.close);
  return dio;
});

/// Dio do loan-service (Go).
final loanDioProvider = Provider<Dio>((ref) {
  final dio = createLoanDio(ref.watch(tokenStorageProvider));
  ref.onDispose(dio.close);
  return dio;
});
