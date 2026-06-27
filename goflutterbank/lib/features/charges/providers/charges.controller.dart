import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/core/providers/core.providers.dart';
import 'package:goflutterbank/features/charges/data/charge.models.dart';
import 'package:goflutterbank/features/charges/data/charges.api.dart';

/// API de cobranças amarrada ao Dio do bank (Java).
final chargesApiProvider =
    Provider<ChargesApi>((ref) => ChargesApi(ref.watch(bankDioProvider)));

@immutable
class ChargesState {
  const ChargesState({
    required this.loading,
    required this.incoming,
    required this.outgoing,
    required this.tab,
    this.error,
  });

  /// Estado inicial: carregando, sem listas, aba "Recebidas".
  static const ChargesState initial = ChargesState(
    loading: true,
    incoming: <Charge>[],
    outgoing: <Charge>[],
    tab: 0,
  );

  final bool loading;
  final List<Charge> incoming;
  final List<Charge> outgoing;

  /// 0 = Recebidas, 1 = Enviadas.
  final int tab;
  final String? error;

  ChargesState copyWith({
    bool? loading,
    List<Charge>? incoming,
    List<Charge>? outgoing,
    int? tab,
    String? error,
    bool clearError = false,
  }) =>
      ChargesState(
        loading: loading ?? this.loading,
        incoming: incoming ?? this.incoming,
        outgoing: outgoing ?? this.outgoing,
        tab: tab ?? this.tab,
        error: clearError ? null : (error ?? this.error),
      );
}

final chargesControllerProvider =
    NotifierProvider<ChargesController, ChargesState>(ChargesController.new);

/// Dono do estado da tela de Cobranças: carrega recebidas/enviadas e age sobre elas.
class ChargesController extends Notifier<ChargesState> {
  @override
  ChargesState build() {
    load();
    return ChargesState.initial;
  }

  ChargesApi get _api => ref.read(chargesApiProvider);

  /// Recarrega as duas listas em paralelo.
  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final results = await Future.wait([_api.incoming(), _api.outgoing()]);
      state = state.copyWith(
        loading: false,
        incoming: results[0],
        outgoing: results[1],
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Não foi possível carregar as cobranças.',
      );
    }
  }

  void setTab(int tab) => state = state.copyWith(tab: tab);

  /// Aprova/paga uma cobrança recebida e recarrega as listas.
  Future<void> approve(String id) async {
    await _api.approve(id);
    await load();
  }

  /// Recusa uma cobrança recebida e recarrega as listas.
  Future<void> reject(String id) async {
    await _api.reject(id);
    await load();
  }

  /// Cria uma nova cobrança e recarrega as listas.
  Future<void> createCharge({
    required String payerCpf,
    required double amount,
  }) async {
    await _api.create(payerCpf: payerCpf, amount: amount);
    await load();
  }
}
