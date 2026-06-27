import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goflutterbank/core/providers/core.providers.dart';
import 'package:goflutterbank/core/storage/token.storage.dart';
import 'package:goflutterbank/main.dart';

/// TokenStorage falso: evita o plugin nativo (indisponível em testes) e
/// simula "sem sessão salva".
class _FakeTokenStorage implements TokenStorage {
  @override
  Future<String?> read() async => null;
  @override
  Future<void> save(String token) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets('app inicia e cai na tela de login quando não há sessão', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStorageProvider.overrideWithValue(_FakeTokenStorage())],
        child: const LumoApp(),
      ),
    );
    // splash -> bootstrap (token nulo) -> redirect para /login
    await tester.pumpAndSettle();

    expect(find.text('Lumo'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });
}
