import 'package:flutter/foundation.dart';

/// Resposta do `POST /api/auth/login` → `{ "token": "..." }`.
@immutable
class AuthResponse {
  const AuthResponse({required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      AuthResponse(token: json['token'] as String);

  final String token;
}

/// Perfil do usuário (`UserResponse` do bank).
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.accountId,
    required this.balance,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'].toString(),
        name: json['name'] as String,
        email: json['email'] as String,
        accountId: json['accountId'].toString(),
        balance: (json['balance'] as num).toDouble(),
      );

  final String id;
  final String name;
  final String email;
  final String accountId;
  final double balance;

  /// Iniciais para o avatar (ex.: "Marina Alves" → "MA").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
