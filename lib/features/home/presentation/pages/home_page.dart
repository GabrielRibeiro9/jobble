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
      iconColor: Colors.blue,
      isUnread: true,
    ),
    NotificationItem(
      title: 'Pagamento recebido',
      description: 'Sua transferência de R\$ 250,00 foi concluída com sucesso.',
      time: 'há 2 horas',
      icon: LucideIcons.circle_check,
      iconColor: Colors.green,
    ),
    NotificationItem(
      title: 'Nova avaliação',
      description:
          'João Silva te avaliou com 5 estrelas: "Excelente profissional!".',
      time: 'Ontem',
      icon: LucideIcons.star,
      iconColor: Colors.amber,
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
                          color: Colors.white.withValues(alpha: 0.25),
                          child: _isOfflineByInactivity
                              ? Builder(
                                  builder: (context) {
                                    final isDark =
                                        Theme.of(context).brightness ==
                                        Brightness.dark;
                                    return Center(
                                      child: Text(
                                        'Aperte para entrar online',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
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
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
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
      return Container(
        color: context.colors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLoader(),
              const SizedBox(height: 16),
              const Text(
                'Carregando mapa...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderColor: Colors.blue.withValues(alpha: 0.3),
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
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : context.colors.themePrimary.withValues(
                                  alpha: 0.15,
                                ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.colors.themePrimary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
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

  Widget _buildIconButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () {},
          customBorder: const CircleBorder(),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, {Color? color}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color ?? Colors.black, size: 24),
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
                color: context.colors.themePrimary,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.surface, width: 2),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25),
        ),
        child: BlocBuilder<HomeJobsBloc, HomeJobsState>(
          builder: (context, state) {
            String earningsText = '0.00';
            if (state is HomeJobsLoaded) {
              earningsText = NumberFormat.currency(
                symbol: '',
                locale: 'pt_BR',
              ).format(state.summary.totalEarnings);
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'R\$',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                if (state is HomeJobsLoading)
                  const Padding(
                    padding: EdgeInsets.all(2),
                    child: AppLoader(),
                  )
                else
                  Text(
                    earningsText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
      left: 16,
      right: 16,
      child: BlocBuilder<HomeJobsBloc, HomeJobsState>(
        builder: (context, state) {
          debugPrint('EarningsSummaryCard: Estado atual do Bloc: $state');

          if (state is HomeJobsLoading) {
            return Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(child: AppLoader()),
            );
          }

          if (state is HomeJobsError) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.triangle_alert,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ops! Algo deu errado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _homeJobsBloc.add(GetCompletedJobsTodayRequested()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tentar novamente',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is! HomeJobsLoaded) {
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('Aguardando dados...')),
            );
          }

          final lastJob = state.summary.jobs.isNotEmpty
              ? state.summary.jobs.last
              : null;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top section with close button (left) and value (center)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Stack(
                    children: [
                      // Close button (left)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _showEarningsSummary = false),
                          child: const Icon(
                            LucideIcons.x,
                            size: 24,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      // Earnings display (centered)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'R\$',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                NumberFormat.currency(
                                  symbol: '',
                                  locale: 'pt_BR',
                                ).format(state.summary.totalEarnings),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE5E5E5)),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      if (lastJob != null) ...[
                        Text(
                          'Hoje às ${DateFormat('HH:mm').format(DateTime.parse(lastJob['updatedAt']))}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastJob['description'] ?? 'Serviço Prestado',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Nenhum serviço prestado hoje',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fique online para começar a receber pedidos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      const Text(
                        'Ver todos os ganhos',
                        style: TextStyle(
                          color: Color(0xFF276EF1),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildMinimalistToggle() {
    return GestureDetector(
      onTap: toggleOnline,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isOnline ? context.colors.themePrimary : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOnline) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ONLINE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ] else ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'OFFLINE',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
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
      margin: const EdgeInsets.all(16).copyWith(bottom: 100),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${request.clientName} precisa dos seus serviços',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                final r = _pendingRequests.isNotEmpty ? _pendingRequests[0] : null;
                if (r != null && r.serviceRequestId.isNotEmpty) {
                  _notificationDataSource.markAsRead(r.notificationId).catchError((_) {});
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.themePrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ver mais',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 13,
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
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final baseColor = isDark ? Colors.white10 : Colors.black12;
            final highlightColor = isDark ? Colors.white38 : Colors.black26;

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
