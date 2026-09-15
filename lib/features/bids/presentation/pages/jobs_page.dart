import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/core/widgets/app_status_chip.dart';
import 'package:flutter_tcc/features/bids/data/datasources/bid_remote_data_source.dart';
import 'package:flutter_tcc/features/bids/data/models/org_match_model.dart';
import 'package:flutter_tcc/features/bids/presentation/pages/match_details_page.dart';
import 'package:flutter_tcc/features/bids/presentation/widgets/job_stage_chip.dart';
import 'package:flutter_tcc/injection_container.dart';

/// Serviços: os trabalhos do profissional, dia a dia.
///
/// Mantém o desenho da antiga agenda — a faixa de dias e a lista do dia — mas
/// com os chamados de verdade, do que espera resposta ao que já foi concluído.
/// O dia de cada trabalho é a data do contrato, a proposta na devolutiva ou a
/// pedida pelo cliente; sem nenhuma, o dia em que o chamado chegou.
class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  static const _daysBefore = 7;
  static const _daysTotal = 28;
  static const _dayWidth = 56.0;
  static const _dayGap = AppSpacing.xs;

  final _dataSource = sl<BidRemoteDataSource>();

  late final DateTime _today;
  late DateTime _selected;
  late final List<DateTime> _days;
  late final ScrollController _strip;

  List<OrgMatch> _jobs = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selected = _today;
    _days = List.generate(
      _daysTotal,
      (index) => _today.add(Duration(days: index - _daysBefore)),
    );
    // Abre com hoje à vista, e não com o primeiro dia da faixa.
    _strip = ScrollController(
      initialScrollOffset: (_daysBefore - 1) * (_dayWidth + _dayGap),
    );
    _load();
  }

  @override
  void dispose() {
    _strip.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final matches = await _dataSource.listMatches();
      if (!mounted) return;
      setState(() {
        _jobs = matches.where((m) => m.stage != JobStage.closed).toList();
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<OrgMatch> _jobsOn(DateTime day) =>
      _jobs.where((job) => _sameDay(job.when, day)).toList()
        ..sort((a, b) => a.when.compareTo(b.when));

  Future<void> _open(OrgMatch job) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchDetailsPage(serviceRequestId: job.requestId),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final dayJobs = _jobsOn(_selected);

    return Column(
      children: [
        _buildStrip(),
        Expanded(
          child: _loading && _jobs.isEmpty
              ? const AppLoaderCentered()
              : _error != null && _jobs.isEmpty
              ? AppEmptyState(
                  icon: LucideIcons.triangle_alert,
                  title: 'Não foi possível carregar',
                  description: _error,
                  actionLabel: 'Tentar de novo',
                  onAction: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      0,
                      AppSpacing.screenH,
                      // Espaço para a barra de abas.
                      120,
                    ),
                    children: [
                      if (dayJobs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xl),
                          child: AppEmptyState(
                            icon: LucideIcons.calendar_x,
                            title: 'Nenhum trabalho neste dia',
                            description:
                                'Chamados, propostas e serviços aparecem no '
                                'dia combinado.',
                          ),
                        )
                      else
                        for (final job in dayJobs)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _JobCard(job: job, onTap: () => _open(job)),
                          ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  /// Faixa de dias. O dia selecionado é o bloco lima; o ponto embaixo diz que
  /// há trabalho naquele dia, e hoje ganha o rótulo "HOJE".
  Widget _buildStrip() {
    final colors = context.colors;

    return SizedBox(
      height: 92,
      child: ListView.separated(
        controller: _strip,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm,
        ),
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(width: _dayGap),
        itemBuilder: (context, index) {
          final day = _days[index];
          final selected = _sameDay(day, _selected);
          final isToday = _sameDay(day, _today);
          final hasJobs = _jobsOn(day).isNotEmpty;
          final ink = selected ? colors.onPrimary : colors.textPrimary;

          return GestureDetector(
            onTap: () => setState(() => _selected = day),
            child: AnimatedContainer(
              duration: AppDuration.normal,
              curve: AppCurve.standard,
              width: _dayWidth,
              decoration: BoxDecoration(
                color: selected ? colors.primary : colors.surface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: selected ? colors.primary : colors.borderLight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday
                        ? 'HOJE'
                        : DateFormat('EEE', 'pt_BR')
                              .format(day)
                              .replaceAll('.', '')
                              .toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      color: selected ? ink : colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    day.day.toString().padLeft(2, '0'),
                    style: AppTypography.numeric.copyWith(
                      color: ink,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasJobs
                          ? (selected ? ink : colors.accentText)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.onTap});

  final OrgMatch job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$ ');
    final value = job.value;

    final time = job.hasAgreedDate
        ? DateFormat('HH:mm').format(job.when)
        : 'Chegou às ${DateFormat('HH:mm').format(job.when)}';

    final place = job.addressLine != null
        ? '${job.addressLine} · ${job.location ?? ''}'
        : '${job.location ?? 'Local não informado'} · '
              '${job.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Antes da escolha o nome não existe para o profissional
                    // — o backend nem o envia.
                    Text(
                      job.clientName ?? 'Nome liberado quando o cliente escolher você',
                      style: AppTypography.bodySmall.copyWith(
                        color: job.clientName != null
                            ? colors.textBody
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              JobStageChip(stage: job.stage),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: colors.borderLight),
          const SizedBox(height: AppSpacing.md),
          AppMetaRow(
            icon: LucideIcons.clock,
            text: time,
            emphasized: job.hasAgreedDate,
            trailing: Text(
              value != null ? money.format(value) : 'A combinar',
              style: AppTypography.numeric.copyWith(
                color: value != null ? colors.textPrimary : colors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppMetaRow(
            icon: job.addressLine != null ? LucideIcons.map_pin : LucideIcons.lock,
            text: place,
          ),
        ],
      ),
    );
  }
}
