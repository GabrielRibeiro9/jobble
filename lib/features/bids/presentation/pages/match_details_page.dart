import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
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
        title: const Text(
          'Detalhes da Solicitação',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.trash_2, color: colors.textSecondary),
            onPressed: _dismiss,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: AppLoader())
          : _request == null
          ? Center(
              child: Text(
                'Erro ao carregar detalhes',
                style: TextStyle(color: colors.textSecondary),
              ),
            )
          : Column(
              children: [
                Expanded(child: _buildContent(colors, req!)),
                if (match == null || match.bidValue == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _respond(context),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Responder'),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cliente',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.user,
                  size: 20,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                req.client.name ?? 'Cliente',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Descrição do Serviço',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            req.description,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          if (req.address != null) ...[
            const SizedBox(height: 24),
            Text(
              'Endereço',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.map_pin,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${req.address!.street}, ${req.address!.number}\n${req.address!.city} - ${req.address!.state}',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Informações da Solicitação',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _infoRow(colors, 'Status', _statusLabel(req.status)),
          _infoRow(
            colors,
            'Urgência',
            req.isEmergency ? 'Emergência' : 'Normal',
          ),
          if (req.scheduledAt != null)
            _infoRow(
              colors,
              'Agendado para',
              '${req.scheduledAt!.day.toString().padLeft(2, '0')}/${req.scheduledAt!.month.toString().padLeft(2, '0')}/${req.scheduledAt!.year}',
            ),
          if (match != null && match.bidValue != null) ...[
            const SizedBox(height: 24),
            Text(
              'Sua Resposta',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _infoRow(
              colors,
              'Valor proposto',
              'R\$ ${match.bidValue!.toStringAsFixed(2)}',
            ),
            if (match.serviceType != null)
              _infoRow(
                colors,
                'Tipo',
                match.serviceType == 'IMMEDIATE'
                    ? 'Atendimento Imediato'
                    : 'Serviço Agendado',
              ),
            if (match.proposedDate != null)
              _infoRow(
                colors,
                'Data proposta',
                '${match.proposedDate!.day.toString().padLeft(2, '0')}/${match.proposedDate!.month.toString().padLeft(2, '0')}/${match.proposedDate!.year}',
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(AppColorsTheme colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
