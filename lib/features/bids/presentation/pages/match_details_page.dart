import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/injection_container.dart';
import 'package:flutter_tcc/features/bids/data/datasources/bid_remote_data_source.dart';
import 'package:flutter_tcc/features/bids/data/models/service_request_detail_model.dart';
import 'package:flutter_tcc/features/bids/presentation/pages/response_page.dart';

class MatchDetailsPage extends StatefulWidget {
  final String serviceRequestId;
  final String clientName;

  const MatchDetailsPage({
    super.key,
    required this.serviceRequestId,
    required this.clientName,
  });

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final dataSource = BidRemoteDataSource(dioClient: sl<DioClient>());
  ServiceRequestDetailModel? _request;
  bool _loading = true;

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final req = _request;
    final match = req != null && req.professionalMatches.isNotEmpty
        ? req.professionalMatches.first
        : null;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: AppSize.iconButton + AppSpacing.md + AppSpacing.xs,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppCircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Voltar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('Solicitação'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: AppCircleIconButton(
              icon: LucideIcons.trash_2,
              tooltip: 'Descartar',
              onPressed: _dismiss,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: AppLoader())
          : req == null
          ? const AppEmptyState(
              icon: LucideIcons.triangle_alert,
              title: 'Não foi possível carregar',
              description: 'Tente abrir a solicitação novamente.',
            )
          : Column(
              children: [
                Expanded(child: _buildContent(colors, req)),
                if (match == null || match.bidValue == null)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        0,
                        AppSpacing.screenH,
                        AppSpacing.md,
                      ),
                      child: AppPrimaryButton(
                        label: 'Responder',
                        onPressed: () => _respond(context),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildContent(AppColorsTheme colors, ServiceRequestDetailModel req) {
    final match = req.professionalMatches.isNotEmpty
        ? req.professionalMatches.first
        : null;

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
                        req.client.name ?? 'Cliente',
                        style: AppTypography.title.copyWith(
                          color: colors.textPrimary,
                        ),
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
              'Endereço',
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.map_pin,
                    size: 18,
                    color: colors.textHint,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${req.address!.street}, ${req.address!.number}\n'
                      '${req.address!.city} - ${req.address!.state}',
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
              AppListRow(title: 'Status', value: _statusLabel(req.status)),
              AppListRow(
                title: 'Urgência',
                value: req.isEmergency ? 'Emergência' : 'Normal',
              ),
              if (req.scheduledAt != null)
                AppListRow(
                  title: 'Agendado para',
                  value: _formatDate(req.scheduledAt!),
                ),
            ],
          ),
          if (match != null && match.bidValue != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppListGroup(
              header: 'Sua resposta',
              children: [
                AppListRow(
                  title: 'Valor proposto',
                  value: 'R\$ ${match.bidValue!.toStringAsFixed(2)}',
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
      'ACCEPTED' => 'Aceito',
      'IN_PROGRESS' => 'Em andamento',
      'COMPLETED' => 'Concluído',
      'CANCELED' => 'Cancelado',
      _ => status,
    };
  }

  void _dismiss() {
    Navigator.of(context).pop();
  }

  void _respond(BuildContext context) {
    final match = _request!.professionalMatches.isNotEmpty
        ? _request!.professionalMatches.first
        : null;
    if (match == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResponsePage(
          serviceMatchId: match.id,
          clientName: widget.clientName,
          onSubmitted: () {
            Navigator.of(context).pop();
            _fetchDetails();
          },
        ),
      ),
    );
  }
}
