import 'package:dio/dio.dart';
import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/features/auth/data/models/auth.models.dart';

/// Chamadas de autenticação e perfil contra o serviço bancário (Java).
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// `POST /api/auth/login` → token JWT.
  Future<AuthResponse> login({required String email, required String password}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthResponse.fromJson(res.data!);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// `POST /api/users/register` → perfil criado (não retorna token; faça login em seguida).
  Future<UserProfile> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/users/register',
        data: {'name': name, 'email': email, 'cpf': cpf, 'password': password},
      );
      return UserProfile.fromJson(res.data!);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// `GET /api/users/me` → perfil do usuário autenticado.
  Future<UserProfile> me() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/users/me');
      return UserProfile.fromJson(res.data!);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}
