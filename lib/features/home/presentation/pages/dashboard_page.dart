import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_balance_card.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/core/widgets/app_status_chip.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/bids/data/datasources/bid_remote_data_source.dart';
import 'package:flutter_tcc/features/bids/data/models/org_match_model.dart';
import 'package:flutter_tcc/features/bids/presentation/pages/match_details_page.dart';
import 'package:flutter_tcc/features/bids/presentation/widgets/job_stage_chip.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/domain/contract_repository.dart';
import 'package:flutter_tcc/features/contracts/presentation/pages/contract_detail_page.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_bloc.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_event.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_state.dart';
import 'package:flutter_tcc/features/home/presentation/pages/inbox_page.dart';
import 'package:flutter_tcc/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_tcc/injection_container.dart';

/// A home do profissional: o que precisa dele agora e o que está em curso.
///
/// Substitui o mapa. A pergunta que o profissional traz ao abrir o app não é
/// "onde estou", é "o que tenho para fazer" — chamados a responder, contratos
/// a preencher ou assinar, serviços em andamento e quanto entrou hoje. As
/// mensagens viram o botão do canto, porque são o aviso do que já está aqui.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key, required this.onOpenTab});

  /// Troca a aba da casca: "ver todos" leva a Serviços (1) ou Contratos (2).
  final ValueChanged<int> onOpenTab;

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage>
    with WidgetsBindingObserver {
  static const _jobsTab = 1;
  static const _contractsTab = 2;

  final _bids = sl<BidRemoteDataSource>();
  final _contracts = sl<ContractRepository>();
  final _notifications = sl<NotificationRemoteDataSource>();
  late final HomeJobsBloc _earnings = sl<HomeJobsBloc>()
    ..add(GetCompletedJobsTodayRequested());

  List<OrgMatch> _matches = const [];
  List<ContractSummary> _contractItems = const [];
  int _unread = 0;
  bool _loading = true;
  String? _error;
  bool _online = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _restoreOnline();
    // Chamado novo precisa aparecer sem o profissional puxar a tela.
    _poll = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _load(silent: true),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthBloc>().add(UserRequested());
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _earnings.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load(silent: true);
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
      _earnings.add(GetCompletedJobsTodayRequested());
    }

    try {
      final results = await Future.wait([
        _bids.listMatches(),
        _contracts.list(),
      ]);
      final unread = await _notifications.fetchUnreadCount().catchError(
        (Object _) => _unread,
      );
      if (!mounted) return;
      setState(() {
        _matches = results[0] as List<OrgMatch>;
        _contractItems = results[1] as List<ContractSummary>;
        _unread = unread;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  // -------------------------------------------------------------------------
  // Online / offline — local, como antes: após 4h sem abrir o app, volta
  // para offline.
  // -------------------------------------------------------------------------

  Future<void> _restoreOnline() async {
    final prefs = await SharedPreferences.getInstance();
    final wasOnline = prefs.getBool('wasOnline') ?? false;
    final last = prefs.getInt('lastOnlineTime');
    final recent =
        last != null &&
        DateTime.now().millisecondsSinceEpoch - last < 4 * 60 * 60 * 1000;
    if (mounted) setState(() => _online = wasOnline && recent);
  }

  Future<void> _setOnline(bool value) async {
    setState(() => _online = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wasOnline', value);
    if (value) {
      await prefs.setInt(
        'lastOnlineTime',
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Navegação
  // -------------------------------------------------------------------------

  Future<void> _push(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) _load(silent: true);
  }

  void _openMatch(OrgMatch match) =>
      _push(MatchDetailsPage(serviceRequestId: match.requestId));

  void _openContract(String id) => _push(ContractDetailPage(contractId: id));

  void _openInbox() => _push(
    const Scaffold(
      appBar: AppBackAppBar(
        title: 'Mensagens',
        subtitle: 'Avisos de chamados, escolhas e contratos.',
      ),
      body: InboxPage(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pendingResponses = _matches
        .where((m) => m.stage == JobStage.awaitingResponse)
        .toList();
    final awaitingClient = _matches
        .where((m) => m.stage == JobStage.awaitingClient)
        .length;
    final contractsToAct = _contractItems
        .where((c) => c.needsAttention)
        .toList();
    final openWork =
        _matches.where((m) => m.stage.isOpenWork).toList()
          ..sort((a, b) => a.when.compareTo(b.when));

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            // Espaço para a barra de abas.
            120,
          ),
          children: [
            _Header(unread: _unread, onInbox: _openInbox),
            const SizedBox(height: AppSpacing.xl),
            _OnlineCard(online: _online, onChanged: _setOnline),
            const SizedBox(height: AppSpacing.sm),
            _EarningsCard(
              bloc: _earnings,
              onSeeJobs: () => widget.onOpenTab(_jobsTab),
            ),
            const SizedBox(height: AppSpacing.section),
            AppSectionHeader(
              title: pendingResponses.length + contractsToAct.length > 0
                  ? 'Pendências · ${pendingResponses.length + contractsToAct.length}'
                  : 'Pendências',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildPending(pendingResponses, contractsToAct),
            if (awaitingClient > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              _InfoCard(
                icon: LucideIcons.clock,
                text: awaitingClient == 1
                    ? '1 chamado aceito está esperando a escolha do cliente.'
                    : '$awaitingClient chamados aceitos estão esperando a '
                          'escolha do cliente.',
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            AppSectionHeader(
              title: 'Serviços em aberto',
              actionLabel: openWork.isNotEmpty ? 'Ver todos' : null,
              onAction: () => widget.onOpenTab(_jobsTab),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_loading && _matches.isEmpty)
              const SizedBox.shrink()
            else if (openWork.isEmpty)
              const _InfoCard(
                icon: LucideIcons.briefcase,
                text:
                    'Quando um cliente escolher você, o serviço aparece aqui '
                    'até ser concluído.',
              )
            else
              for (final job in openWork.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _OpenJobCard(job: job, onTap: () => _openMatch(job)),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPending(
    List<OrgMatch> responses,
    List<ContractSummary> contracts,
  ) {
    if (_loading && _matches.isEmpty && _contractItems.isEmpty) {
      return const AppCard(
        child: Center(child: AppLoader()),
      );
    }

    if (_error != null && _matches.isEmpty && _contractItems.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _error!,
              style: AppTypography.body.copyWith(
                color: context.colors.textBody,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSecondaryButton(
              label: 'Tentar de novo',
              expanded: false,
              onPressed: _load,
            ),
          ],
        ),
      );
    }

    if (responses.isEmpty && contracts.isEmpty) {
      return const _InfoCard(
        icon: LucideIcons.circle_check,
        text: 'Nada esperando você agora.',
      );
    }

    return AppListGroup(
      children: [
        for (final match in responses.take(3))
          AppListRow(
            icon: LucideIcons.bell,
            iconColor: AppColorsTheme.categorical[0],
            title: match.displayTitle,
            subtitle:
                'Responder · ${match.location ?? 'Local não informado'} · '
                '${match.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km',
            onTap: () => _openMatch(match),
          ),
        if (responses.length > 3)
          AppListRow(
            title: 'Ver os ${responses.length} chamados',
            onTap: () => widget.onOpenTab(_jobsTab),
          ),
        for (final contract in contracts.take(3))
          AppListRow(
            icon: LucideIcons.file_text,
            iconColor: AppColorsTheme.categorical[1],
            title: contract.title.isEmpty ? contract.code : contract.title,
            subtitle: '${contract.status.label} · ${contract.clientName}',
            onTap: () => _openContract(contract.id),
          ),
        if (contracts.length > 3)
          AppListRow(
            title: 'Ver todos os contratos',
            onTap: () => widget.onOpenTab(_contractsTab),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.unread, required this.onInbox});

  final int unread;
  final VoidCallback onInbox;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final name = state is AuthSuccess ? state.user?.name : null;
              final first = name?.trim().split(RegExp(r'\s+')).first ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    first.isEmpty ? 'Olá' : 'Olá, $first',
                    style: AppTypography.h1.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Seu dia de trabalho no Jobble.',
                    style: AppTypography.descriptor.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            AppCircleIconButton(
              icon: LucideIcons.inbox,
              tooltip: 'Mensagens',
              onPressed: onInbox,
            ),
            if (unread > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: colors.accentText,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const _OnlineCard({required this.online, required this.onChanged});

  final bool online;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppDuration.normal,
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? colors.accentText : colors.textHint,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? 'Você está online' : 'Você está offline',
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  online
                      ? 'Recebendo chamados da sua região.'
                      : 'Fique online para receber chamados novos.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: online, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.bloc, required this.onSeeJobs});

  final HomeJobsBloc bloc;
  final VoidCallback onSeeJobs;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$ ');

    return BlocBuilder<HomeJobsBloc, HomeJobsState>(
      bloc: bloc,
      builder: (context, state) {
        final amount = switch (state) {
          HomeJobsLoaded() => money.format(state.summary.totalEarnings),
          HomeJobsLoading() => '—',
          _ => money.format(0),
        };

        final support = switch (state) {
          HomeJobsLoaded() => switch (state.summary.jobs.length) {
            0 => 'Nenhum serviço concluído hoje',
            1 => '1 serviço concluído hoje',
            final n => '$n serviços concluídos hoje',
          },
          HomeJobsError() => 'Não foi possível carregar os ganhos',
          _ => 'Carregando…',
        };

        return AppBalanceCard(
          label: 'Ganhos de hoje',
          amount: amount,
          footer: Row(
            children: [
              Expanded(
                child: Text(
                  support,
                  style: AppTypography.title.copyWith(
                    color: colors.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppPrimaryButton(
                label: 'Ver serviços',
                expanded: false,
                onPressed: onSeeJobs,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      tone: AppCardTone.sunken,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(color: colors.textBody),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenJobCard extends StatelessWidget {
  const _OpenJobCard({required this.job, required this.onTap});

  final OrgMatch job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final when = job.hasAgreedDate
        ? DateFormat("EEE, d 'de' MMM · HH:mm", 'pt_BR').format(job.when)
        : 'Data a combinar';

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              JobStageChip(stage: job.stage),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            job.clientName ?? 'Cliente',
            style: AppTypography.bodySmall.copyWith(color: colors.textBody),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppMetaRow(icon: LucideIcons.calendar, text: when),
          const SizedBox(height: AppSpacing.xxs),
          AppMetaRow(
            icon: LucideIcons.map_pin,
            text: job.addressLine ?? job.location ?? 'Local não informado',
          ),
        ],
      ),
    );
  }
}
