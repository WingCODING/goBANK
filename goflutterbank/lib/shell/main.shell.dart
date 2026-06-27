import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';

/// Shell com a barra de navegação inferior (4 abas) que envolve Home, Transferir,
/// Cobranças e Empréstimo. Recebe o [StatefulNavigationShell] do go_router e
/// preserva o estado de cada aba (IndexedStack interno do StatefulShellRoute).
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// +1 = avançou (aba à direita), -1 = voltou (aba à esquerda). Define o
  /// sentido do slide entre abas e é atualizado quando o índice muda.
  int _direction = 1;

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Início'),
    _NavItem(icon: Icons.near_me_outlined, activeIcon: Icons.near_me_rounded, label: 'Transferir'),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Cobranças'),
    _NavItem(icon: Icons.account_balance_outlined, activeIcon: Icons.account_balance, label: 'Empréstimo'),
  ];

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIndex = oldWidget.navigationShell.currentIndex;
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex != oldIndex) {
      // didUpdateWidget roda antes do build, então o slide já usa o sentido certo.
      _direction = newIndex > oldIndex ? 1 : -1;
    }
  }

  void _onTap(int index) {
    final shell = widget.navigationShell;
    // initialLocation:true volta a aba para a raiz ao tocar nela já estando ativa.
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        // Slide direcional entre abas: a entrante vem do lado de _direction e a
        // que sai desliza para o lado oposto. A key por índice sinaliza a troca;
        // o conteúdo é o IndexedStack interno do StatefulShellRoute, então o
        // estado de cada aba é preservado.
        transitionBuilder: (child, animation) {
          final isLeaving = animation.status == AnimationStatus.reverse ||
              animation.status == AnimationStatus.dismissed;
          final begin = isLeaving
              ? Offset(-_direction.toDouble(), 0) // sai para o lado oposto
              : Offset(_direction.toDouble(), 0); // entra pelo lado de _direction
          return SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(shell.currentIndex),
          child: shell,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: _items[i],
                      selected: i == shell.currentIndex,
                      onTap: () => _onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.iconMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? item.activeIcon : item.icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
