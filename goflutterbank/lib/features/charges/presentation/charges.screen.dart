import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:goflutterbank/core/api/api.exception.dart';
import 'package:goflutterbank/core/theme/app.colors.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';
import 'package:goflutterbank/core/theme/app.typography.dart';
import 'package:goflutterbank/core/utils/currency.dart';
import 'package:goflutterbank/features/charges/data/charge.models.dart';
import 'package:goflutterbank/features/charges/providers/charges.controller.dart';
import 'package:goflutterbank/shared/widgets/avatar.dart';
import 'package:goflutterbank/shared/widgets/form.card.dart';
import 'package:goflutterbank/shared/widgets/primary.button.dart';
import 'package:goflutterbank/shared/widgets/secondary.button.dart';
import 'package:goflutterbank/shared/widgets/status.badge.dart';

/// Tela 05 — Cobranças (raiz de aba: sem voltar, sem bottomNavigationBar).
class ChargesScreen extends ConsumerWidget {
  const ChargesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chargesControllerProvider);
    final notifier = ref.read(chargesControllerProvider.notifier);

    final list = state.tab == 0 ? state.incoming : state.outgoing;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Cobranças', style: AppText.titleScreen),
                  const Spacer(),
                  _NewChargePill(onTap: () => context.push('/charges/new')),
                ],
              ),
              const SizedBox(height: 16),
              _SegmentedTabs(
                tab: state.tab,
                onChanged: notifier.setTab,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildBody(context, ref, state, list),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ChargesState state,
    List<Charge> list,
  ) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (list.isEmpty) {
      final message = state.tab == 0
          ? 'Nenhuma cobrança'
          : 'Você ainda não enviou cobranças';
      return Center(
        child: Text(
          message,
          style: AppText.body.copyWith(color: AppColors.textTertiary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _ChargeCard(
        charge: list[index],
        // Botões só na aba Recebidas (tab 0) e para cobranças pendentes.
        showActions: state.tab == 0,
      ),
    );
  }
}

/// Pílula "Novo" no topo direito do header.
class _NewChargePill extends StatelessWidget {
  const _NewChargePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Novo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tabs segmentadas Recebidas / Enviadas.
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.tab, required this.onChanged});

  final int tab;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Recebidas',
              active: tab == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Enviadas',
              active: tab == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.badge),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// Card de uma cobrança.
class _ChargeCard extends ConsumerWidget {
  const _ChargeCard({required this.charge, required this.showActions});

  final Charge charge;
  final bool showActions;

  ChargeBadge get _badge => switch (charge.status) {
        ChargeStatus.pending => ChargeBadge.pending,
        ChargeStatus.approved => ChargeBadge.approved,
        ChargeStatus.rejected => ChargeBadge.rejected,
        ChargeStatus.unknown => ChargeBadge.pending,
      };

  String get _shortId {
    final id = charge.id;
    return id.length >= 8 ? id.substring(0, 8) : id;
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    // captura o messenger antes do await para não usar o BuildContext após o gap async
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(chargesControllerProvider.notifier).approve(charge.id);
    } on ApiException catch (e) {
      _showError(messenger, e.message);
    } catch (_) {
      _showError(messenger, 'Não foi possível aprovar a cobrança.');
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(chargesControllerProvider.notifier).reject(charge.id);
    } on ApiException catch (e) {
      _showError(messenger, e.message);
    } catch (_) {
      _showError(messenger, 'Não foi possível recusar a cobrança.');
    }
  }

  void _showError(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showButtons = showActions && charge.status == ChargeStatus.pending;

    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InitialsAvatar(initials: '#', size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cobrança', style: AppText.titleM),
                    const SizedBox(height: 2),
                    Text('#$_shortId', style: AppText.caption),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatBRL(charge.amount), style: AppText.titleM),
                  const SizedBox(height: 6),
                  StatusBadge(status: _badge),
                ],
              ),
            ],
          ),
          if (showButtons) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Recusar',
                    onPressed: () => _reject(context, ref),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Aprovar',
                    variant: PrimaryButtonVariant.success,
                    onPressed: () => _approve(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
