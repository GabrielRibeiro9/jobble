import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_bloc.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_state.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/service_summary_sheet.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/notifications_sheet.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_bloc.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_event.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_state.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/injection_container.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tcc/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_tcc/features/bids/presentation/pages/match_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isOnline = false;
  final List<_IncomingRequest> _pendingRequests = [];
  final NotificationRemoteDataSource _notificationDataSource =
      NotificationRemoteDataSource(dioClient: sl<DioClient>());

  bool _showEarningsSummary = false;
  bool _isOfflineByInactivity = false;
  late HomeJobsBloc _homeJobsBloc;
  Timer? _pollTimer;

  // Mock data — Notificações
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Novo pedido próximo',
      description:
          'Um novo serviço de Elétrica está disponível a 2.5km de você.',
      time: 'há 5 min',
      icon: LucideIcons.map_pin,
      iconColor: AppColorsTheme.categorical[5],
      isUnread: true,
    ),
    NotificationItem(
      title: 'Pagamento recebido',
      description: 'Sua transferência de R\$ 250,00 foi concluída com sucesso.',
      time: 'há 2 horas',
      icon: LucideIcons.circle_check,
      iconColor: AppColorsTheme.categorical[4],
    ),
    NotificationItem(
      title: 'Nova avaliação',
      description:
          'João Silva te avaliou com 5 estrelas: "Excelente profissional!".',
      time: 'Ontem',
      icon: LucideIcons.star,
      iconColor: AppColorsTheme.categorical[2],
      isUnread: true,
    ),
  ];

  // Map
  late final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;

  // Mock data — Atendimentos Recentes
  static const List<Map<String, String>> _recentServices = [
    {
      'service': 'Instalação Elétrica',
      'clientName': 'João Silva',
      'startTime': '09:30',
      'endTime': '10:45',
      'address': 'Rua das Flores, 123 - Centro',
      'value': 'R\$ 85,00',
    },
    {
      'service': 'Reparo Hidráulico',
      'clientName': 'Maria Oliveira',
      'startTime': '11:15',
      'endTime': '12:00',
      'address': 'Av. Paulista, 1500 - Bela Vista',
      'value': 'R\$ 65,00',
    },
    {
      'service': 'Pintura Residencial',
      'clientName': 'Pedro Santos',
      'startTime': '14:00',
      'endTime': '16:30',
      'address': 'Rua Augusta, 456 - Jardins',
      'value': 'R\$ 100,00',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeJobsBloc = sl<HomeJobsBloc>()..add(GetCompletedJobsTodayRequested());
    _initLocation();
    _checkInactivity();
    _fetchUnreadNotifications();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchUnreadNotifications();
    });
    // Defer UserRequested to avoid race with login navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(UserRequested());
      }
    });
  }

  Future<void> _fetchUnreadNotifications() async {
    try {
      final notifications = await _notificationDataSource.fetchUnread();
      if (!mounted) return;
      setState(() {
        _pendingRequests.clear();
        _pendingRequests.addAll(notifications.map((n) => _IncomingRequest(
          id: n.id,
          notificationId: n.id,
          clientName: n.personName,
          serviceRequestId: n.serviceRequestId ?? '',
        )));
      });
    } catch (e) {
      debugPrint('Erro ao buscar notificações: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (isOnline) {
        _saveOnlineTime();
      }
    }
  }

  Future<void> _checkInactivity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOnlineTime = prefs.getInt('lastOnlineTime');
    final wasOnline = prefs.getBool('wasOnline') ?? false;

    if (wasOnline && lastOnlineTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final fourHoursInMillis = 4 * 60 * 60 * 1000;

      if ((now - lastOnlineTime) > fourHoursInMillis) {
        setState(() {
          _isOfflineByInactivity = true;
          isOnline = false;
        });
      }
    }
  }

  Future<void> _saveOnlineTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastOnlineTime', DateTime.now().millisecondsSinceEpoch);
    await prefs.setBool('wasOnline', true);
  }

  void _fetchJobsToday(BuildContext context) {
    context.read<HomeJobsBloc>().add(GetCompletedJobsTodayRequested());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _homeJobsBloc.close();
    super.dispose();
  }

  void _toggleSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceSummarySheet(
        services: _recentServices,
        totalEarnings: 'R\$ 250,00',
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationsSheet(notifications: _notifications),
    );
  }

  Future<void> _initLocation() async {
    try {
      final status = await Permission.locationWhenInUse.request();

      if (!status.isGranted) {
        _setDefaultLocation();
        return;
      }

      // Tenta pegar a última posição conhecida primeiro (mais rápido, sem NMEA)
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        setState(() {
          _currentPosition = LatLng(
            lastPosition.latitude,
            lastPosition.longitude,
          );
          _isLoadingLocation = false;
        });
        return;
      }

      // Fallback: pega posição atual com timeout
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
            ),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Location timeout'),
          );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      // Default: São Paulo
      _currentPosition = const LatLng(-23.5505, -46.6333);
      _isLoadingLocation = false;
    });
  }

  void toggleOnline() async {
    setState(() {
      isOnline = !isOnline;
      if (isOnline) {
        _isOfflineByInactivity = false;
      } else {
        _pendingRequests.clear();
      }
    });
    if (isOnline) {
      await _saveOnlineTime();
    }
  }

  void _goOnlineFromInactivity() async {
    setState(() {
      isOnline = true;
      _isOfflineByInactivity = false;
    });
    await _saveOnlineTime();
  }

  void _dismissRequest(int index) {
    final request = _pendingRequests[index];
    _notificationDataSource
        .markAsRead(request.notificationId)
        .catchError((_) {});
    setState(() {
      _pendingRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeJobsBloc,
      child: Builder(
        builder: (context) {
          return Stack(
            children: [
              // 2. Map (Real OpenStreetMap)
              _buildMap(),

              // 3. Top Earnings Badge
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: SizedBox(
                    height: 50,
                    child: Center(child: _buildEarningsBadge(context)),
                  ),
                ),
              ),

              // 4. Map Overlay (Glassy when offline)
              if (!isOnline)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _goOnlineFromInactivity,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          color: context.colors.overlay,
                          child: _isOfflineByInactivity
                              ? Center(
                                  child: Text(
                                    'Toque para ficar online',
                                    style: AppTypography.h3.copyWith(
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

              // 7. Incoming Request Stack
              if (_pendingRequests.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildPendingRequestStack(),
                ),

              // 6. Dark Overlay when summary is open
              if (_showEarningsSummary)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _showEarningsSummary = false),
                    child: ColoredBox(color: context.colors.overlay),
                  ),
                ),

              // 8. Earnings Summary Card
              if (_showEarningsSummary) _buildEarningsSummaryCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    final pos = _currentPosition;

    if (_isLoadingLocation || pos == null) {
      return ColoredBox(
        color: context.colors.background,
        child: const AppLoaderCentered(label: 'Carregando mapa...'),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urlTemplate = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, state) {
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: pos, initialZoom: 16),
          children: [
            TileLayer(
              urlTemplate: urlTemplate,
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.flutter_tcc',
              retinaMode: RetinaMode.isHighDensity(context),
            ),
            // Overlay de Raio de Atuação (Ultra-Safe)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: pos,
                  radius: state.raioAtuacao * 1000,
                  useRadiusInMeter: true,
                  color: context.colors.primary.withValues(alpha: 0.10),
                  borderColor: context.colors.primary.withValues(alpha: 0.45),
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: pos,
                  width: 120,
                  height: 120,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Ponto de localização (centralizado no ponto GPS)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(
                            alpha: 0.22,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: context.colors.onPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      // Avatar subindo a partir do ponto central
                      Transform.translate(
                        offset: const Offset(0, -42),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            String? avatarUrl;
                            String fallbackName = '';

                            if (authState is AuthSuccess &&
                                authState.user != null) {
                              final org = authState.user!.organization;
                              avatarUrl = org?.avatarUrl;
                              fallbackName = org?.name ?? '';
                            }

                            return ProfileAvatar(
                              size: 56,
                              imageUrl: avatarUrl,
                              fallbackName: fallbackName,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Botão circular sobre o mapa. Usa a cor de alto contraste para se
  /// destacar de qualquer tile, claro ou escuro.
  Widget _buildIconButton(IconData icon, {VoidCallback? onPressed}) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: 48,
      child: Material(
        color: colors.inverse,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? () {},
          child: Icon(icon, size: 22, color: colors.onInverse),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, {Color? color}) {
    final colors = context.colors;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.inverse,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: color ?? colors.onInverse),
    );
  }

  Widget _buildNotificationButton() {
    final hasUnread = _notifications.any((n) => n.isUnread);

    return Stack(
      children: [
        _buildIconButton(LucideIcons.bell, onPressed: _showNotifications),
        if (hasUnread)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  void _centerMap() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 16);
    }
  }

  Widget _buildEarningsBadge(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint(
          'Earnings badge tapped! Current state: $_showEarningsSummary',
        );
        setState(() {
          _showEarningsSummary = !_showEarningsSummary;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          // Pill de alto contraste: precisa ler sobre qualquer tile do mapa.
          color: context.colors.inverse,
          borderRadius: AppRadius.pillAll,
        ),
        child: BlocBuilder<HomeJobsBloc, HomeJobsState>(
          builder: (context, state) {
            final colors = context.colors;
            var earningsText = '0,00';
            if (state is HomeJobsLoaded) {
              earningsText = NumberFormat.currency(
                symbol: '',
                locale: 'pt_BR',
              ).format(state.summary.totalEarnings);
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r'R$',
                  style: AppTypography.title.copyWith(color: colors.onInverse),
                ),
                const SizedBox(width: AppSpacing.xxs),
                if (state is HomeJobsLoading)
                  AppLoader(size: 18, color: colors.onInverse)
                else
                  Text(
                    earningsText,
                    style: AppTypography.numeric.copyWith(
                      color: colors.onInverse,
                      fontSize: 20,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEarningsSummaryCard() {
    return Positioned(
      top: 60,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: BlocBuilder<HomeJobsBloc, HomeJobsState>(
        builder: (context, state) {
          final colors = context.colors;

          BoxDecoration cardDecoration() => BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: colors.border, width: AppSize.border),
          );

          if (state is HomeJobsLoading) {
            return Container(
              height: 220,
              decoration: cardDecoration(),
              child: const Center(child: AppLoader(size: 28)),
            );
          }

          if (state is HomeJobsError) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: cardDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.triangle_alert,
                      color: colors.error,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Não foi possível carregar',
                    style: AppTypography.h3.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppPrimaryButton(
                    label: 'Tentar novamente',
                    onPressed: () =>
                        _homeJobsBloc.add(GetCompletedJobsTodayRequested()),
                  ),
                ],
              ),
            );
          }

          if (state is! HomeJobsLoaded) {
            return Container(
              height: 100,
              decoration: cardDecoration(),
              child: Center(
                child: Text(
                  'Aguardando dados...',
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final lastJob = state.summary.jobs.isNotEmpty
              ? state.summary.jobs.last
              : null;

          return Container(
            decoration: cardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      AppCircleIconButton(
                        icon: LucideIcons.x,
                        tooltip: 'Fechar',
                        onPressed: () =>
                            setState(() => _showEarningsSummary = false),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            NumberFormat.currency(
                              symbol: r'R$ ',
                              locale: 'pt_BR',
                            ).format(state.summary.totalEarnings),
                            style: AppTypography.numeric.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.iconButton),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.borderLight),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      if (lastJob != null) ...[
                        Text(
                          'Hoje às '
                          '${DateFormat('HH:mm').format(DateTime.parse(lastJob['updatedAt']))}',
                          style: AppTypography.h3.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          lastJob['description'] ?? 'Serviço prestado',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Nenhum serviço prestado hoje',
                          style: AppTypography.h3.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Fique online para começar a receber pedidos.',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todos os ganhos'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Removed _buildSummaryPanel and _buildServiceCard as they are now in ServiceSummarySheet

  /// Pill de estado de operação. Online usa o acento; offline fica neutro.
  Widget _buildMinimalistToggle() {
    final colors = context.colors;
    final foreground = isOnline ? colors.onPrimary : colors.textSecondary;

    return GestureDetector(
      onTap: toggleOnline,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isOnline ? colors.primary : colors.surfaceStrong,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: AppTypography.title.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestStack() {
    final count = _pendingRequests.length;
    const double peekHeight = 12.0;
    const double cardHeight = 68.0;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md).copyWith(bottom: 110),
      child: SizedBox(
        height: cardHeight + (count - 1) * peekHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = count - 1; i >= 0; i--)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                bottom: i * peekHeight,
                right: 0,
                left: 0,
                child: Transform.scale(
                  scale: 1.0 - (i * 0.03),
                  alignment: Alignment.bottomCenter,
                  child: _buildRequestCard(_pendingRequests[i], i == 0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(_IncomingRequest request, bool isTop) {
    final colors = context.colors;

    Widget card = Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: colors.border, width: AppSize.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
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
                LucideIcons.sparkle,
                size: 18,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${request.clientName} precisa dos seus serviços',
                style: AppTypography.body.copyWith(color: colors.textPrimary),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: () {
                final r = _pendingRequests.isNotEmpty
                    ? _pendingRequests[0]
                    : null;
                if (r != null && r.serviceRequestId.isNotEmpty) {
                  _notificationDataSource
                      .markAsRead(r.notificationId)
                      .catchError((_) {});
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MatchDetailsPage(
                        serviceRequestId: r.serviceRequestId,
                        clientName: r.clientName,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  'Ver mais',
                  style: AppTypography.label.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isTop) {
      card = Dismissible(
        key: ValueKey(request.id),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => _dismissRequest(0),
        background: const SizedBox.shrink(),
        secondaryBackground: const SizedBox.shrink(),
        child: card,
      );
    }

    return card;
  }
}

class _IncomingRequest {
  const _IncomingRequest({
    required this.id,
    required this.notificationId,
    required this.clientName,
    required this.serviceRequestId,
  });

  final String id;
  final String notificationId;
  final String clientName;
  final String serviceRequestId;
}

class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final colors = context.colors;
            final baseColor = colors.textPrimary.withValues(alpha: 0.06);
            final highlightColor = colors.textPrimary.withValues(alpha: 0.24);

            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
