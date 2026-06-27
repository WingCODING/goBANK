import 'package:flutter/material.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';

/// Raios de borda (seção 2.4 do design.md).
class AppRadii {
  AppRadii._();
  static const input = 14.0;
  static const card = 20.0;
  static const button = 16.0;
  static const chip = 12.0;
  static const badge = 8.0;
  static const logo = 18.0;
}

/// Espaçamentos-chave (seção 2.3).
class AppSpacing {
  AppSpacing._();
  static const gutter = 24.0; // padding horizontal das telas
  static const block = 20.0; // entre blocos de formulário
}

/// Sombras (seção 2.5).
class AppShadows {
  AppShadows._();
  static const card = BoxShadow(color: Color(0x0F16181D), blurRadius: 24, offset: Offset(0, 8));
  static const primary = BoxShadow(color: Color(0x33EC0B5A), blurRadius: 24, offset: Offset(0, 10));
  static const balance = BoxShadow(color: Color(0x40EC0B5A), blurRadius: 30, offset: Offset(0, 14));
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
        prefixIconColor: AppColors.iconMuted,
        suffixIconColor: AppColors.iconMuted,
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, width: 1.5),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppText.link,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide(color: color, width: width),
      );
}
