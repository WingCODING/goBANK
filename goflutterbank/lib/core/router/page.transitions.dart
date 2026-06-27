import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transições de tela reutilizáveis para o go_router.
///
/// Cada helper devolve uma [CustomTransitionPage] pronta para ser usada no
/// `pageBuilder` de uma [GoRoute]. As curvas/durações são padronizadas aqui
/// para manter o movimento coerente entre todas as telas.
class PageTransitions {
  PageTransitions._();

  static const Duration _duration = Duration(milliseconds: 320);
  static const Duration _reverse = Duration(milliseconds: 260);
  static const Curve _curve = Curves.easeOutCubic;

  /// Slide horizontal (entra da direita) + fade. Para telas empurradas por
  /// cima de outra, ex.: Cobranças → Nova cobrança.
  static CustomTransitionPage<T> slideFromRight<T>(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      transitionDuration: _duration,
      reverseTransitionDuration: _reverse,
      child: child,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(parent: animation, curve: _curve);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  /// Fade + leve subida. Bom para troca de telas "irmãs" (login ↔ cadastro)
  /// e para entrar no app a partir do splash.
  static CustomTransitionPage<T> fadeThrough<T>(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      transitionDuration: _duration,
      reverseTransitionDuration: _reverse,
      child: child,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(parent: animation, curve: _curve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
