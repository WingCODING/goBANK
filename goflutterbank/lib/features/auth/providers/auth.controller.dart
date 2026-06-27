import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goflutterbank/core/providers/core.providers.dart';
import 'package:goflutterbank/features/auth/data/auth.api.dart';
import 'package:goflutterbank/features/auth/data/models/auth.models.dart';

/// API de autenticação amarrada ao Dio do bank.
final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(bankDioProvider)));

enum AuthStatus { unknown, authenticated, unauthenticated }

@immutable
class AuthState {
  const AuthState({required this.status, this.user, this.isSubmitting = false});

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = null,
        isSubmitting = false;

  final AuthStatus status;
  final UserProfile? user;
  final bool isSubmitting;

  AuthState copyWith({AuthStatus? status, UserProfile? user, bool? isSubmitting}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Dono do estado de sessão: bootstrap (token salvo), login, cadastro e logout.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _bootstrap();
    return const AuthState.unknown();
  }

  AuthApi get _api => ref.read(authApiProvider);

  /// Ao abrir o app: se há token salvo e ainda é válido, entra autenticado.
  /// Qualquer falha (storage indisponível, token expirado, /me fora do ar) cai
  /// para o login — nunca trava no splash.
  Future<void> _bootstrap() async {
    try {
      final token = await ref.read(tokenStorageProvider).read();
      if (token == null || token.isEmpty) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      final me = await _api.me();
      state = AuthState(status: AuthStatus.authenticated, user: me);
    } catch (_) {
      try {
        await ref.read(tokenStorageProvider).clear();
      } catch (_) {
        // ignora: storage pode estar indisponível
      }
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Faz login, persiste o token e carrega o perfil. Relança `ApiException` em falha.
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final auth = await _api.login(email: email, password: password);
      await ref.read(tokenStorageProvider).save(auth.token);
      final me = await _api.me();
      state = AuthState(status: AuthStatus.authenticated, user: me);
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  /// Cria a conta e já autentica em seguida (o registro não devolve token).
  Future<void> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _api.register(name: name, email: email, cpf: cpf, password: password);
      await login(email: email, password: password);
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Recarrega o perfil (ex.: atualizar o saldo após uma transferência).
  /// Silencioso: em caso de erro mantém o perfil atual.
  Future<void> refreshProfile() async {
    try {
      final me = await _api.me();
      state = state.copyWith(user: me);
    } catch (_) {
      // ignora: mantém o estado atual
    }
  }
}
