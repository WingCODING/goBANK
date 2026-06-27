import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda o JWT em armazenamento seguro do SO (Keychain no iOS, Keystore no Android).
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'jwt_token';
  final FlutterSecureStorage _storage;

  Future<void> save(String token) => _storage.write(key: _key, value: token);
  Future<String?> read() => _storage.read(key: _key);
  Future<void> clear() => _storage.delete(key: _key);
}
