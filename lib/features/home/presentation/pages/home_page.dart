import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_bloc.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_state.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';
import 'package:flutter_tcc/core/widgets/star_rating.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/home_drawer.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/service_summary_sheet.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/notifications_sheet.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/home_bottom_sheet.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_bloc.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_event.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_state.dart';
import 'package:flutter_tcc/injection_container.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isOnline = false;
  bool showRequest = false;

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
    _initLocation();
    context.read<AuthBloc>().add(UserRequested());
  }

  void _fetchJobsToday(BuildContext context) {
    context.read<HomeJobsBloc>().add(GetCompletedJobsTodayRequested());
  }

  @override
  void dispose() {
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

  void toggleOnline() {
    setState(() {
      isOnline = !isOnline;
      if (!isOnline) {
        showRequest = false;
      }
    });
  }

  void simulateIncomingRequest() {
    if (!isOnline) return;
    setState(() {
      showRequest = true;
    });
  }

  void acceptOrRejectRequest() {
    setState(() {
      showRequest = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<HomeJobsBloc>()..add(GetCompletedJobsTodayRequested()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: context.colors.background,
            drawer: const HomeDrawer(),
            body: Stack(
              children: [
                // 2. Map (Real OpenStreetMap)
                _buildMap(),

                // 3. Top Action Bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SizedBox(
                      height: 50,
                      child: Stack(
                        children: [
                          // Menu Button (Left)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Builder(
                              builder: (scaffoldContext) => _buildIconButton(
                                Icons.menu,
                                onPressed: () =>
                                    Scaffold.of(scaffoldContext).openDrawer(),
                              ),
                            ),
                          ),
                          // Earnings Pill (Center)
                          Align(
                            alignment: Alignment.center,
                            child: _buildEarningsBadge(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Bottom Toggle Button
                if (!showRequest)
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: _buildMainToggleButton(),
                  ),

                // 5. Incoming Request Overlay
                if (showRequest)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildIncomingRequestCard(),
                  ),

                // 6. Simulation button above card
                if (isOnline && !showRequest)
                  Positioned(
                    top: 120,
                    right: 32,
                    child: Center(
                      child: FloatingActionButton.extended(
                        onPressed: simulateIncomingRequest,
                        backgroundColor: context.colors.themePrimary,
                        elevation: 0,
                        icon: Icon(
                          Icons.notifications_active,
                          color: context.colors.onPrimary,
                        ),
                        label: Text(
                          'Simular Pedido',
                          style: TextStyle(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
              CircularProgressIndicator(color: context.colors.themePrimary),
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
            ),
            // Overlay de Raio de Atuação (Ultra-Safe)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: pos,
                  radius: state.raioAtuacao * 1000,
                  useRadiusInMeter: true,
                  color: Colors.blue.withOpacity(0.1),
                  borderColor: Colors.blue.withOpacity(0.3),
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
                              ? Colors.white.withOpacity(0.2)
                              : context.colors.themePrimary.withOpacity(0.15),
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
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white : Colors.black,
                              width: 3,
                            ),
                          ),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              String? avatarUrl;
                              String fallbackName = 'Você';

                              if (authState is AuthSuccess &&
                                  authState.user != null) {
                                avatarUrl = authState.user!.avatarUrl;
                                fallbackName = authState.user!.name ?? 'Você';
                              }

                              return ProfileAvatar(
                                size: 56,
                                imageUrl: avatarUrl,
                                fallbackName: fallbackName,
                              );
                            },
                          ),
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
            color: Colors.black.withOpacity(0.1),
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
            color: Colors.black.withOpacity(0.1),
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
      onTap: _toggleSummary,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                  '\$',
                  style: TextStyle(
                    color: Color(0xFF2EB086),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                if (state is HomeJobsLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
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

  // Removed _buildSummaryPanel and _buildServiceCard as they are now in ServiceSummarySheet

  Widget _buildMainToggleButton() {
    return GestureDetector(
      onTap: toggleOnline,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isOnline ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOnline ? LucideIcons.power : LucideIcons.power_off,
              color: isOnline ? Colors.white : Colors.grey[300],
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: isOnline ? Colors.white : Colors.grey[300],
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingRequestCard() {
    return Container(
      margin: const EdgeInsets.all(16).copyWith(bottom: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Category badge + Close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Serviços Elétricos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: acceptOrRejectRequest,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Requester Name (Highlight)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'José da Silva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Rating + Verified Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                const Text(
                  '4.95',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  LucideIcons.shield_check,
                  color: Colors.blue[400],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verificado',
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withOpacity(0.08),
          ),

          const SizedBox(height: 16),

          // Trip Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Distance
                Row(
                  children: [
                    Icon(
                      LucideIcons.map_pin,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '3 min (1.1 km) de distância',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Route
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 8,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              bottom: 0,
                              left: 3,
                              child: Container(
                                width: 2,
                                color: Colors.grey[600],
                              ),
                            ),
                            Positioned(
                              top: 6,
                              left: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Descrição do serviço',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Instalação de chuveiro elétrico, troca de tomadas e interruptores, reparo de curto-circuito.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 8,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 6,
                              left: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Endereço',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Rua das Flores, 123 - Centro, São Paulo - SP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Accept Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: acceptOrRejectRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EB086),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aceitar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
