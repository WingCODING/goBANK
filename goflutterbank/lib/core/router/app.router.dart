import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goflutterbank/features/auth/presentation/login.screen.dart';
import 'package:goflutterbank/features/auth/presentation/signup.screen.dart';
import 'package:goflutterbank/features/auth/providers/auth.controller.dart';
import 'package:goflutterbank/features/charges/presentation/charges.screen.dart';
import 'package:goflutterbank/features/charges/presentation/new.charge.screen.dart';
import 'package:goflutterbank/features/home/presentation/home.screen.dart';
import 'package:goflutterbank/features/loan/presentation/loan.screen.dart';
import 'package:goflutterbank/features/splash/presentation/splash.screen.dart';
import 'package:goflutterbank/features/transfer/presentation/transfer.screen.dart';
import 'package:goflutterbank/core/router/page.transitions.dart';
import 'package:goflutterbank/shell/main.shell.dart';

/// Rotas do app.
///
/// - `/splash`, `/login`, `/signup`: fora do shell (sem bottom nav).
/// - Shell com 4 abas (`StatefulShellRoute`): Home, Transferir, Cobranças, Empréstimo.
/// - `/charges/new`: empilhada dentro da aba Cobranças (mantém a bottom nav e a aba ativa).
///
/// O redirect é dirigido pelo estado de autenticação.
final routerProvider = Provider<GoRouter>((ref) {
  // Faz o go_router reavaliar o redirect sempre que o status de auth muda.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider.select((s) => s.status), (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/login' || loc == '/signup';
      final onSplash = loc == '/splash';

      switch (status) {
        case AuthStatus.unknown:
          return onSplash ? null : '/splash';
        case AuthStatus.unauthenticated:
          return onAuthPage ? null : '/login';
        case AuthStatus.authenticated:
          return (onAuthPage || onSplash) ? '/home' : null;
      }
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) => PageTransitions.fadeThrough(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (_, state) => PageTransitions.fadeThrough(state, const SignupScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/transfer', builder: (_, _) => const TransferScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/charges',
                builder: (_, _) => const ChargesScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    pageBuilder: (_, state) =>
                        PageTransitions.slideFromRight(state, const NewChargeScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/loan', builder: (_, _) => const LoanScreen())],
          ),
        ],
      ),
    ],
  );
});
