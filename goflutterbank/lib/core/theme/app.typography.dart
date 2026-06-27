import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';

/// Escala tipográfica do Lumo (seção 2.2 do design.md).
/// Fonte: Inter (quando empacotada); por ora usa a fonte padrão do sistema.
class AppText {
  AppText._();

  static const displayLarge = TextStyle(
      fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const headlineLarge = TextStyle(
      fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const titleScreen = TextStyle(
      fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3);
  static const titleBrand =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const titleM =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const body =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const label =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const caption =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const overline = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8);
  static const button =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onPrimary);
  static const link =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary);
}
