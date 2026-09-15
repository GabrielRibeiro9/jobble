import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';
import 'package:flutter_tcc/core/widgets/app_status_chip.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/injection_container.dart';
import 'package:flutter_tcc/features/bids/data/datasources/bid_remote_data_source.dart';
import 'package:flutter_tcc/features/bids/data/models/service_request_detail_model.dart';
import 'package:flutter_tcc/features/bids/presentation/pages/response_page.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/presentation/pages/contract_detail_page.dart';
import 'package:flutter_tcc/features/contracts/presentation/widgets/contract_widgets.dart';

/// Um chamado recebido, na visão do profissional.
///
/// A tela tem dois momentos. Antes de decidir, a única pergunta é "pego este
/// serviço?" — e a ação embaixo são só Recusar e Aceitar. Depois de aceitar,
/// ele já está na lista do cliente e a ação vira a devolutiva: valor, dúvidas,
/// ou os dois. Separar as duas coisas é o ponto do fluxo — dizer que topa não
/// exige saber o preço ainda.
class MatchDetailsPage extends StatefulWidget {
  final String serviceRequestId;

  const MatchDetailsPage({super.key, required this.serviceRequestId});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final dataSource = sl<BidRemoteDataSource>();
  ServiceRequestDetailModel? _request;
  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final data = await dataSource.getServiceRequest(widget.serviceRequestId);
      if (!mounted) return;
      setState(() {
        _request = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erro ao buscar detalhes: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  MatchInfo? get _match {
    final matches = _request?.professionalMatches;
    if (matches == null || matches.isEmpty) return null;
    return matches.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final req = _request;

    return Scaffold(
      appBar: const AppBackAppBar(title: 'Chamado'),
      body: _loading
          ? const Center(child: AppLoader())
          : req == null
          ? const AppEmptyState(
              icon: LucideIcons.triangle_alert,
              title: 'Não foi possível carregar',
              description: 'Tente abrir o chamado novamente.',
            )
          : Column(
              children: [
                Expanded(child: _buildContent(colors, req)),
                _buildActions(),
              ],
            ),
    );
  }

  /// Barra de ação, escolhida pelo estado do chamado. Sem ação disponível ela
  /// desaparece em vez de virar um botão desabilitado — não há nada a fazer.
  Widget _buildActions() {
    final match = _match;
    if (match == null) return const SizedBox.shrink();

    final Widget? actions;

    if (match.status.awaitsDecision) {
      actions = Row(
        children: [
          Expanded(
            child: AppSecondaryButton(
              label: 'Recusar',
              isLoading: false,
              onPressed: _acting ? null : _decline,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppPrimaryButton(
              label: 'Aceitar',
              isLoading: _acting,
              onPressed: _acting ? null : _accept,
            ),
          ),
        ],
      );
    } else if (match.status.canBid) {
      actions = AppPrimaryButton(
        label: match.hasBid ? 'Editar devolutiva' : 'Enviar devolutiva',
        onPressed: _acting ? null : _openBid,
      );
    } else if (match.status == MatchStatus.hired && match.contract != null) {
      // Depois da escolha, o próximo passo é o contrato — é ele que
      // formaliza preço, prazo e garantia entre as duas partes.
      actions = AppPrimaryButton(
        label: 'Abrir contrato',
        onPressed: () => _openContract(match.contract!.id),
      );
    } else {
      actions = null;
    }

    if (actions == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          0,
          AppSpacing.screenH,
          AppSpacing.md,
        ),
        child: actions,
      ),
    );
  }

  Widget _buildContent(AppColorsTheme colors, ServiceRequestDetailModel req) {
    final match = _match;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (match != null) ...[
            _MatchStatusCard(status: match.status),
            const SizedBox(height: AppSpacing.md),
          ],
          if (match?.contract case final contract?) ...[
            AppCard(
              onTap: () => _openContract(contract.id),
              child: Row(
                children: [
                  Icon(LucideIcons.file_text, color: colors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contrato ${contract.code}',
                          style: AppTypography.title.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        ContractStatusChip(
                          status: ContractStatus.fromJson(contract.status),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.textHint),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppCard(
            child: Row(
              children: [
                Container(
                  width: AppSize.categoryIcon,
                  height: AppSize.categoryIcon,
                  decoration: BoxDecoration(
                    color: colors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.user,
                    size: 19,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente',
                        style: AppTypography.caption.copyWith(
                          color: colors.textHint,
                        ),
                      ),
                      Text(
                        req.client.name ?? 'Nome reservado',
                        style: AppTypography.title.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      // Antes da escolha o backend nem envia nome, contato ou
                      // endereço: é a escolha do cliente que os libera.
                      if (!req.clientRevealed)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Nome, contato e endereço são liberados quando o '
                            'cliente escolher você.',
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      // O mesmo selo que o cliente vê do profissional: é o
                      // que diz que o contrato vai ter do outro lado quem ele
                      // diz ser.
                      if (req.client.identityVerified)
                        Row(
                          children: [
                            Icon(
                              LucideIcons.badge_check,
                              size: 14,
                              color: colors.success,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              'Identidade verificada',
                              style: AppTypography.caption.copyWith(
                                color: colors.success,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Descrição do serviço',
            style: AppTypography.label.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            req.description,
            style: AppTypography.body.copyWith(color: colors.textPrimary),
          ),
          if (req.address != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              req.address!.revealed ? 'Endereço' : 'Região',
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    req.address!.revealed
                        ? LucideIcons.map_pin
                        : LucideIcons.lock,
                    size: 18,
                    color: colors.textHint,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _placeText(req.address!, match),
                      style: AppTypography.body.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppListGroup(
            header: 'Informações da solicitação',
            children: [
              AppListRow(title: 'Situação', value: _statusLabel(req.status)),
              AppListRow(
                title: 'Prioridade',
                value: req.isEmergency ? 'Alta (emergência)' : 'Normal',
              ),
              if (req.scheduledAt != null)
                AppListRow(
                  title: 'Agendado para',
                  value: _formatDate(req.scheduledAt!),
                ),
            ],
          ),
          // O detalhamento vem antes da devolutiva: é a resposta do cliente à
          // réplica, e o que o profissional precisa reler para fechar o preço.
          if (match?.clientDetails != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Detalhes enviados pelo cliente',
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Text(
                match!.clientDetails!,
                style: AppTypography.body.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
          if (match != null && match.hasBid) ...[
            const SizedBox(height: AppSpacing.xl),
            AppListGroup(
              header: 'Sua devolutiva',
              children: [
                AppListRow(
                  title: 'Valor proposto',
                  value: match.bidValue != null
                      ? 'R\$ ${match.bidValue!.toStringAsFixed(2)}'
                      : 'A combinar',
                ),
                if (match.serviceType != null)
                  AppListRow(
                    title: 'Tipo',
                    value: match.serviceType == 'IMMEDIATE'
                        ? 'Atendimento imediato'
                        : 'Serviço agendado',
                  ),
                if (match.proposedDate != null)
                  AppListRow(
                    title: 'Data proposta',
                    value: _formatDate(match.proposedDate!),
                  ),
              ],
            ),
            if (match.proQuestion != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Suas dúvidas',
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Text(
                  match.proQuestion!,
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _statusLabel(String status) {
    return switch (status) {
      'SEARCHING' => 'Buscando prestador',
      'PENDING' => 'Aguardando resposta',
      'ACCEPTED' => 'Profissional definido',
      'IN_PROGRESS' => 'Em andamento',
      'COMPLETED' => 'Concluído',
      'CANCELED' => 'Cancelado',
      _ => status,
    };
  }

  Future<void> _accept() async {
    final match = _match;
    if (match == null) return;

    setState(() => _acting = true);
    try {
      await dataSource.acceptMatch(match.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado aceito. Envie sua devolutiva ao cliente.'),
        ),
      );
      await _fetchDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aceitar o chamado: $e')),
      );
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  /// Recusar é definitivo — o chamado sai da lista do profissional —, então
  /// passa por confirmação.
  Future<void> _decline() async {
    final match = _match;
    if (match == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recusar o chamado?'),
        content: const Text(
          'Ele sai da sua lista e o cliente não verá você entre as opções.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Recusar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _acting = true);
    try {
      await dataSource.declineMatch(match.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao recusar o chamado: $e')),
      );
      setState(() => _acting = false);
    }
  }

  Future<void> _openContract(String contractId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContractDetailPage(contractId: contractId),
      ),
    );
    if (mounted) _fetchDetails();
  }

  /// Endereço completo depois da escolha; antes, a região e a distância.
  String _placeText(AddressInfo address, MatchInfo? match) {
    if (address.revealed) {
      return '${address.street ?? ''}, ${address.number ?? 's/n'}\n'
          '${address.regionLabel}';
    }
    final km = match?.distanceKm;
    if (km == null) return address.regionLabel;
    return '${address.regionLabel}\n'
        '${km.toStringAsFixed(1).replaceAll('.', ',')} km de você';
  }

  void _openBid() {
    final match = _match;
    if (match == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResponsePage(
          serviceMatchId: match.id,
          clientName: _request?.client.name ?? 'o cliente',
          initialBidValue: match.bidValue,
          initialServiceType: match.serviceType,
          initialProposedDate: match.proposedDate,
          initialQuestion: match.proQuestion,
          onSubmitted: () {
            Navigator.of(context).pop();
            _fetchDetails();
          },
        ),
      ),
    );
  }
}

/// Onde o profissional está neste chamado, em uma linha.
///
/// É a primeira coisa da tela porque decide o que o resto significa: a mesma
/// descrição de serviço é uma oferta em aberto, um compromisso assumido ou um
/// registro morto, dependendo daqui.
class _MatchStatusCard extends StatelessWidget {
  const _MatchStatusCard({required this.status});

  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (Color color, String label, String support) = switch (status) {
      MatchStatus.pending => (
        colors.warning,
        'Aguardando você',
        'Aceite para entrar na lista do cliente. O valor pode vir depois.',
      ),
      MatchStatus.accepted => (
        colors.info,
        'Você aceitou',
        'O cliente ainda está escolhendo. Uma devolutiva ajuda a decidir.',
      ),
      MatchStatus.hired => (
        colors.success,
        'Você foi escolhido',
        'O cliente fechou com você. Complete os termos e envie o contrato '
            'para formalizar o serviço.',
      ),
      MatchStatus.declined => (
        colors.textHint,
        'Você recusou',
        'Este chamado não está mais na sua lista.',
      ),
      MatchStatus.rejected => (
        colors.textHint,
        'Cliente descartou',
        'O cliente seguiu com outras opções.',
      ),
      MatchStatus.ignored => (
        colors.textHint,
        'Cliente escolheu outro',
        'A solicitação foi fechada com outro profissional.',
      ),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusChip(label: label, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            support,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
