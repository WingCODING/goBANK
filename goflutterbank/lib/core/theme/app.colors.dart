import 'package:flutter/material.dart';

/// Paleta da marca Lumo (seção 2.1 do design.md).
class AppColors {
  AppColors._();

  // Brand / Primary
  static const primary = Color(0xFFEC0B5A);
  static const primaryDark = Color(0xFFC50A4D);
  static const primaryLight = Color(0xFFFCE4EC);
  static const primarySoft = Color(0xFFFDECEF);
  static const onPrimary = Color(0xFFFFFFFF);

  // Neutrals
  static const background = Color(0xFFEDEFF2);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF4F5F7);
  static const border = Color(0xFFE6E8EC);
  static const textPrimary = Color(0xFF16181D);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const iconMuted = Color(0xFF9CA3AF);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFDCFCE7);
  static const warningText = Color(0xFFB45309);
  static const warningBg = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);

  /// Gradiente do cartão de saldo (~135°).
  static const balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}
