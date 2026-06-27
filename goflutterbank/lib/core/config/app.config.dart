/// Configuração de ambiente do app.
///
/// As URLs podem ser sobrescritas em tempo de build, ex.:
///   flutter run --dart-define=BANK_BASE_URL=http://10.0.2.2:8080
///
/// Dica de host por plataforma ao apontar para um backend local:
///   - Emulador Android: 10.0.2.2  (mapeia o localhost da máquina host)
///   - iOS sim / Desktop / Web:   localhost
class AppConfig {
  AppConfig._();

  /// Serviço bancário (Java / Spring Boot).
  static const String bankBaseUrl = String.fromEnvironment(
    'BANK_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Serviço de empréstimos (Go).
  static const String loanBaseUrl = String.fromEnvironment(
    'LOAN_BASE_URL',
    defaultValue: 'http://localhost:8085',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
