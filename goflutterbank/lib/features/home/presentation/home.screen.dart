import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/core/utils/currency.dart';
import 'package:goflutterbank/features/auth/providers/auth.controller.dart';
import 'package:goflutterbank/shared/mock/mock.data.dart';
import 'package:goflutterbank/shared/widgets/action.tile.dart';
import 'package:goflutterbank/shared/widgets/avatar.dart';
import 'package:goflutterbank/shared/widgets/form.card.dart';
import 'package:goflutterbank/shared/widgets/transaction.row.dart';

/// Tela 03 — Home.
/// Cabeçalho com saudação, cartão de saldo (com toggle de visibilidade),
/// atalhos de ação e a lista de últimas movimentações (mock).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hidden = false;

  void _toggleHidden() => setState(() => _hidden = !_hidden);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider.select((s) => s.user));

    final name = user?.name ?? '—';
    final initials = user?.initials ?? '—';
    final balanceText = user == null
        ? '—'
        : (_hidden ? 'R\$ ••••••' : formatBRL(user.balance));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------- Header
              Row(
                children: [
                  InitialsAvatar(
                    initials: initials,
                    size: 40,
                    highlight: true,
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onLongPress: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bem-vinda de volta', style: AppText.caption),
                        Text('Olá, $name', style: AppText.titleM),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _NotificationButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Sem novas notificações'),
                          ),
                        );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ----------------------------------------------------- Balance card
              _BalanceCard(
                balanceText: balanceText,
                hidden: _hidden,
                onToggle: _toggleHidden,
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------- Shortcuts
              Row(
                children: [
                  Expanded(
                    child: ActionTile(
                      icon: Icons.near_me_outlined,
                      label: 'Transferir',
                      onTap: () => context.go('/transfer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionTile(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Cobrar',
                      onTap: () => context.go('/charges'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionTile(
                      icon: Icons.account_balance,
                      label: 'Empréstimo',
                      onTap: () => context.go('/loan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ----------------------------------------------------- Section head
              Row(
                children: [
                  Text('ÚLTIMAS MOVIMENTAÇÕES', style: AppText.overline),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Ver tudo', style: AppText.link),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // -------------------------------------------------- Activity list
              FormCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (var i = 0; i < kMockActivity.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          color: AppColors.border,
                          height: 1,
                          thickness: 1,
                        ),
                      TransactionRow(item: kMockActivity[i]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão circular branco (48x48) com ícone de notificações e um ponto vermelho.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão de saldo com gradiente, círculos translúcidos decorativos
/// e toggle de visibilidade do valor.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balanceText,
    required this.hidden,
    required this.onToggle,
  });

  final String balanceText;
  final bool hidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: const [AppShadows.balance],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Stack(
          children: [
            // Decorative translucent circles on the right.
            Positioned(
              top: -28,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -36,
              right: 30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Saldo disponível',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.70),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onToggle,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: hidden ? 'Mostrar saldo' : 'Ocultar saldo',
                        icon: Icon(
                          hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      balanceText,
                      key: ValueKey<String>(balanceText),
                      style: AppText.headlineLarge.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      kAccountMask,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
