import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/domain/contract_repository.dart';
import 'package:flutter_tcc/features/contracts/presentation/bloc/contract_detail_cubit.dart';
import 'package:flutter_tcc/features/contracts/presentation/pages/contract_document_page.dart';
import 'package:flutter_tcc/features/contracts/presentation/pages/contract_terms_page.dart';
import 'package:flutter_tcc/features/contracts/presentation/pages/sign_contract_page.dart';
import 'package:flutter_tcc/features/contracts/presentation/widgets/contract_widgets.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/verification_center_page.dart';
import 'package:flutter_tcc/features/legal/presentation/widgets/readiness_card.dart';
import 'package:flutter_tcc/injection_container.dart';

final _dateTime = DateFormat('dd/MM/yyyy HH:mm');

/// Um contrato na visão do profissional: onde ele está, o que falta e o que
/// dá para fazer agora.
///
/// Os botões saem de `allowedActions`, que vem do servidor. A tela não decide
/// o fluxo — só apresenta o próximo passo que o servidor liberou.
class ContractDetailPage extends StatelessWidget {
  const ContractDetailPage({super.key, required this.contractId});

  final String contractId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractDetailCubit(
        repository: sl<ContractRepository>(),
        contractId: contractId,
      )..load(),
      child: const ContractDetailView(),
    );
  }
}

class ContractDetailView extends StatelessWidget {
  const ContractDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<ContractDetailCubit, ContractDetailState>(
      listenWhen: (previous, current) =>
          previous.error != current.error ||
          previous.message != current.message,
      listener: (context, state) {
        final text = state.error ?? state.message;
        if (text == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor: state.error != null ? colors.error : null,
            ),
          );
        context.read<ContractDetailCubit>().clearMessages();
      },
      builder: (context, state) {
        final cubit = context.read<ContractDetailCubit>();
        final contract = state.contract;

        return Scaffold(
          appBar: AppBackAppBar(
            title: contract == null ? 'Contrato' : contract.code,
            actions: [
              if (contract?.can(ContractAction.download) ?? false)
                IconButton(
                  tooltip: 'Receber cópia por e-mail',
                  icon: const Icon(LucideIcons.mail),
                  onPressed: state.acting ? null : cubit.sendCopy,
                ),
            ],
          ),
          body: contract == null
              ? state.loading
                    ? const AppLoaderCentered()
                    : AppEmptyState(
                        icon: LucideIcons.triangle_alert,
                        title: 'Não foi possível carregar',
                        description: state.error,
                        actionLabel: 'Tentar de novo',
                        onAction: cubit.load,
                      )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => cubit.load(silent: true),
                        child: _ContractBody(contract: contract),
                      ),
                    ),
                    _ActionBar(contract: contract, acting: state.acting),
                  ],
                ),
        );
      },
    );
  }
}

class _ContractBody extends StatelessWidget {
  const _ContractBody({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ContractDetailCubit>();
    final showReadiness = !contract.status.isFinal &&
        contract.status != ContractStatus.signed &&
        contract.status != ContractStatus.awaitingConfirmation;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xl,
      ),
      children: [
        _StatusCard(contract: contract),
        if (contract.status == ContractStatus.changesRequested &&
            contract.changeRequest != null) ...[
          const SizedBox(height: AppSpacing.md),
          _ChangeRequestCard(request: contract.changeRequest!),
        ],
        if (showReadiness) ...[
          const SizedBox(height: AppSpacing.md),
          ReadinessCard(
            title: 'Seu cadastro',
            readiness: contract.myReadiness,
            onFix: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VerificationCenterPage(),
                ),
              );
              cubit.load(silent: true);
            },
          ),
          if (!contract.otherReadiness.ready) ...[
            const SizedBox(height: AppSpacing.md),
            ReadinessCard(
              title: 'Cadastro do cliente',
              readiness: contract.otherReadiness,
              footnote:
                  'O cliente é avisado para completar o cadastro quando você '
                  'tenta enviar o contrato.',
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.section),
        _TermsSummary(contract: contract),
        if (contract.missingTerms.isNotEmpty &&
            contract.can(ContractAction.editTerms)) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            bordered: true,
            child: Text(
              'Para enviar, falta: ${contract.missingTerms.join(', ')}.',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.warning,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.section),
        _SignaturesGroup(contract: contract),
        const SizedBox(height: AppSpacing.md),
        _DocumentCard(contract: contract),
        if (contract.timeline.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          _Timeline(events: contract.timeline),
        ],
        if (contract.can(ContractAction.cancel) ||
            contract.can(ContractAction.terminate)) ...[
          const SizedBox(height: AppSpacing.section),
          _DangerZone(contract: contract),
        ],
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.contract});

  final ContractModel contract;

  String _support() {
    final c = contract;
    return switch (c.status) {
      ContractStatus.draft =>
        'Revise os termos e envie para o cliente assinar. O texto definitivo '
            'é gerado no envio.',
      ContractStatus.changesRequested =>
        'O cliente pediu ajustes. Edite os termos e reenvie.',
      ContractStatus.pendingSignatures =>
        c.hasSigned(ContractParty.provider)
            ? 'Você já assinou. Falta o cliente.'
            : c.hasSigned(ContractParty.client)
            ? 'O cliente já assinou. Falta você.'
            : 'Aguardando as assinaturas das duas partes.',
      ContractStatus.signed =>
        'Contrato em vigor. Quando terminar o serviço, marque como concluído.',
      ContractStatus.awaitingConfirmation =>
        'Você marcou o serviço como concluído. Aguardando o cliente confirmar.',
      ContractStatus.completed => 'Serviço concluído e confirmado pelo cliente.',
      ContractStatus.canceled =>
        'Cancelado${c.canceledBy == null ? '' : ' pelo ${c.canceledBy!.label.toLowerCase()}'}'
            '${c.cancelReason == null ? '.' : ': ${c.cancelReason}'}',
      ContractStatus.terminated =>
        'Rescindido${c.canceledBy == null ? '' : ' pelo ${c.canceledBy!.label.toLowerCase()}'}'
            '${c.cancelReason == null ? '.' : ': ${c.cancelReason}'}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ContractStatusChip(status: contract.status),
              const Spacer(),
              if (contract.version > 0)
                Text(
                  'versão ${contract.version}',
                  style: AppTypography.caption.copyWith(color: colors.textHint),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            contract.serviceTitle,
            style: AppTypography.h3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            'Cliente: ${contract.clientName}',
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _support(),
            style: AppTypography.body.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ChangeRequestCard extends StatelessWidget {
  const _ChangeRequestCard({required this.request});

  final ContractChangeRequest request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      bordered: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedido do cliente',
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            request.message,
            style: AppTypography.body.copyWith(color: colors.textPrimary),
          ),
          if (request.counterProposalCents != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Contraproposta: ${formatCents(request.counterProposalCents!)}',
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _TermsSummary extends StatelessWidget {
  const _TermsSummary({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final terms = contract.terms;
    String orDash(String? value) =>
        (value == null || value.isEmpty) ? 'A definir' : value;

    return AppListGroup(
      header: 'Termos',
      children: [
        AppListRow(
          title: 'Valor',
          value: terms.priceCents == null ? 'A definir' : formatCents(terms.priceCents!),
        ),
        AppListRow(
          title: 'Pagamento',
          value: orDash(terms.paymentMethod?.label),
          subtitle: terms.paymentTerms,
        ),
        AppListRow(
          title: 'Início',
          value: orDash(terms.startDate == null ? null : formatBrDate(terms.startDate!)),
        ),
        AppListRow(
          title: 'Término previsto',
          value: orDash(
            terms.estimatedEndDate == null
                ? null
                : formatBrDate(terms.estimatedEndDate!),
          ),
        ),
        AppListRow(title: 'Garantia', value: '${terms.warrantyDays} dias'),
        AppListRow(
          title: 'Materiais',
          value: orDash(terms.materialsResponsibility?.label),
          subtitle: terms.materialsNotes,
        ),
      ],
    );
  }
}

class _SignaturesGroup extends StatelessWidget {
  const _SignaturesGroup({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget row(ContractParty party, String name) {
      final signature = contract.signatures
          .where((s) => s.party == party)
          .firstOrNull;

      return AppListRow(
        title: '${party.label} — $name',
        subtitle: signature != null
            ? 'Assinou em ${_dateTime.format(signature.signedAt)}'
            : contract.version == 0
            ? 'Contrato ainda não enviado'
            : 'Assinatura pendente',
        trailing: Icon(
          signature != null ? LucideIcons.circle_check : LucideIcons.clock,
          size: 20,
          color: signature != null ? colors.success : colors.textHint,
        ),
      );
    }

    return AppListGroup(
      header: 'Assinaturas',
      children: [
        row(ContractParty.client, contract.clientName),
        row(ContractParty.provider, contract.organizationName),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hash = contract.contentHash;

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ContractDocumentPage(contract: contract),
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.file_text, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ler o contrato',
                  style: AppTypography.title.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  contract.isPreview || hash == null
                      ? 'Prévia com os dados atuais'
                      : 'Versão ${contract.version} · ${hash.substring(0, 12)}…',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textHint),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.events});

  final List<ContractEventInfo> events;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico',
          style: AppTypography.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final event in events.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.textHint,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.label,
                        style: AppTypography.body.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (event.message != null)
                        Text(
                          '"${event.message}"',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      Text(
                        _dateTime.format(event.createdAt),
                        style: AppTypography.caption.copyWith(
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<ContractDetailCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contract.can(ContractAction.cancel))
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.error),
            onPressed: () async {
              final reason = await showReasonDialog(
                context,
                title: 'Cancelar o contrato?',
                message:
                    'O cliente é avisado e volta a poder escolher outro '
                    'profissional para a solicitação.',
                confirmLabel: 'Cancelar contrato',
              );
              if (reason != null) await cubit.cancel(reason);
            },
            child: const Text('Cancelar contrato'),
          ),
        if (contract.can(ContractAction.terminate))
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.error),
            onPressed: () async {
              final reason = await showReasonDialog(
                context,
                title: 'Rescindir o contrato?',
                message:
                    'O contrato já foi assinado. A rescisão fica registrada com '
                    'o motivo e segue a cláusula de rescisão combinada.',
                confirmLabel: 'Rescindir',
              );
              if (reason != null) await cubit.terminate(reason);
            },
            child: const Text('Rescindir contrato'),
          ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.contract, required this.acting});

  final ContractModel contract;
  final bool acting;

  Future<void> _openTerms(BuildContext context) {
    final cubit = context.read<ContractDetailCubit>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const ContractTermsPage(),
        ),
      ),
    );
  }

  Future<void> _openSign(BuildContext context) {
    final cubit = context.read<ContractDetailCubit>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const SignContractPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<ContractDetailCubit>();
    final buttons = <Widget>[];

    if (contract.can(ContractAction.editTerms)) {
      buttons.add(
        AppSecondaryButton(
          label: 'Editar termos',
          onPressed: acting ? null : () => _openTerms(context),
        ),
      );
    }

    if (contract.can(ContractAction.submit)) {
      buttons.add(
        AppPrimaryButton(
          label: 'Enviar',
          isLoading: acting,
          onPressed: () async {
            final confirmed = await confirmAction(
              context,
              title: 'Enviar para assinatura?',
              message:
                  'O texto do contrato é congelado e enviado ao cliente. Depois '
                  'disso, qualquer mudança gera uma nova versão.',
              confirmLabel: 'Enviar',
            );
            if (confirmed) await cubit.submit();
          },
        ),
      );
    }

    if (contract.can(ContractAction.sign)) {
      buttons.add(
        contract.canSign
            ? AppPrimaryButton(
                label: 'Revisar e assinar',
                onPressed: acting ? null : () => _openSign(context),
              )
            : Text(
                'Só o responsável legal da organização assina o contrato.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
      );
    }

    if (contract.can(ContractAction.markCompleted)) {
      buttons.add(
        AppPrimaryButton(
          label: 'Marcar como concluído',
          isLoading: acting,
          onPressed: () async {
            final confirmed = await confirmAction(
              context,
              title: 'Serviço concluído?',
              message:
                  'O cliente recebe um aviso para confirmar a conclusão ou '
                  'apontar pendências.',
              confirmLabel: 'Marcar como concluído',
            );
            if (confirmed) await cubit.markCompleted();
          },
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.xs,
          AppSpacing.screenH,
          AppSpacing.md,
        ),
        child: buttons.length == 2
            ? Row(
                children: [
                  Expanded(child: buttons[0]),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: buttons[1]),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < buttons.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.xs),
                    buttons[i],
                  ],
                ],
              ),
      ),
    );
  }
}
