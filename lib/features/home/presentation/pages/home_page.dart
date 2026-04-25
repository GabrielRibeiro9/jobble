import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:flutter_tcc/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/home_drawer.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/service_summary_sheet.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/main_toggle_button.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/earnings_floating_card.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/home_bottom_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isOnline = false;
  bool showRequest = false;
  bool showEarningsCard = false;

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

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleSummary() {
    setState(() {
      showEarningsCard = !showEarningsCard;
    });
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
    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const HomeDrawer(),
      body: Stack(
        children: [
          // 1. Real OpenStreetMap
          _buildMap(),

          // 2. Main Toggle Button (Circular)
          if (!showRequest)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 110),
                child: MainToggleButton(
                  isOnline: isOnline,
                  onTap: toggleOnline,
                ),
              ),
            ),

          // 3. Expandable Bottom Dashboard
          if (!showRequest)
            HomeBottomDashboard(
              isOnline: isOnline,
              onToggleDrawer: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ServiceSummarySheet(
                    services: _recentServices,
                    totalEarnings: 'R\$250,00',
                  ),
                );
              },
            ),

          if (!showRequest)
            Positioned(
              bottom: 140,
              left: 24,
              child: _buildIconButton(Icons.help_outline, onPressed: () {}),
            ),
          if (!showRequest)
            Positioned(
              bottom: 140,
              right: 24,
              child: _buildIconButton(Icons.my_location, onPressed: _centerMap),
            ),

          // 5. Dark Backdrop for Earnings Card
          if (showEarningsCard)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => showEarningsCard = false),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),

          // 7. Lateral Top Buttons (Help & Settings) - Dimmed by Backdrop
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 36.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(
                    Icons.help_outline,
                    onPressed: () {
                      // Help action
                    },
                  ),
                  const Spacer(),
                  _buildIconButton(
                    LucideIcons.settings,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 8. Earnings Floating Card
          if (showEarningsCard)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: EarningsFloatingCard(
                  lastService: _recentServices.first,
                  onSeeAll: () {
                    setState(() => showEarningsCard = false);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ServiceSummarySheet(
                        services: _recentServices,
                        totalEarnings: 'R\$ 250,00',
                      ),
                    );
                  },
                ),
              ),
            ),

          // 9. Central Earnings Badge - Always on Top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 36.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: _buildEarningsBadge(),
              ),
            ),
          ),

          // 6. Incoming Request Overlay
          if (showRequest)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildIncomingRequestCard(),
            ),

          // 7. Simulation button above card
          if (isOnline && !showRequest)
            Positioned(
              top: 180,
              right: 24,
              child: _buildIconButton(
                Icons.notifications_active,
                onPressed: simulateIncomingRequest,
              ),
            ),

          // Help and Location buttons above Bottom Sheet
          if (!showRequest)
            Positioned(
              bottom: 140,
              left: 24,
              child: _buildIconButton(Icons.help_outline, onPressed: () {}),
            ),
          if (!showRequest)
            Positioned(
              bottom: 140,
              right: 24,
              child: _buildIconButton(Icons.my_location, onPressed: _centerMap),
            ),
        ],
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
              const CupertinoActivityIndicator(),
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
    final colors = context.colors;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.textPrimary.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () {},
          customBorder: const CircleBorder(),
          child: Icon(icon, color: colors.textPrimary, size: 24),
        ),
      ),
    );
  }

  void _centerMap() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 16);
    }
  }

  Widget _buildEarningsBadge() {
    return GestureDetector(
      onTap: _toggleSummary,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
        alignment: Alignment.center,
        child: Text(
          'R\$ 250,00',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingRequestCard() {
    return Container(
      margin: const EdgeInsets.all(16).copyWith(bottom: 32),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border, width: 1),
            ),
            child: Row(
              children: [
                const ProfileAvatar(size: 48, fallbackName: 'José da Silva'),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'José da Silva',
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const StarRating(rating: 3.7, hiring: 14),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border, width: 1),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoria',
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Serviços Elétricos',
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Botao para fechar o card
                    IconButton(
                      onPressed: acceptOrRejectRequest,
                      icon: const Icon(Icons.close),
                      iconSize: 16,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        backgroundColor: context.colors.textPrimary.withOpacity(
                          0.1,
                        ),
                        foregroundColor: context.colors.textPrimary,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Aprox. 17 min de distância',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 16,
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
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    left: 0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: context.colors.textPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      'Descrição do serviço',
                                      style: TextStyle(
                                        color: context.colors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Instalação de chuveiro elétrico, troca de tomadas e interruptores, reparo de curto-circuito, instalação de luminárias e ventiladores de teto, reparo de chuveiro elétrico.',
                                      style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 16,
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
                                      decoration: BoxDecoration(
                                        color: context.colors.textPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text(
                                    'Endereço',
                                    style: TextStyle(
                                      color: context.colors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Rua das Flores, 123 - Centro, São Paulo - SP, 01000-000',
                                    style: TextStyle(
                                      color: context.colors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: acceptOrRejectRequest,
                    child: const Text('Aceitar'),
                  ),
                ),
              ],
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
