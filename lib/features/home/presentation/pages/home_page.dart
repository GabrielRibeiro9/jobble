import 'dart:ui';
import 'package:flutter/material.dart';
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
import 'package:flutter_tcc/features/home/presentation/widgets/offline_dashboard.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  bool isOnline = false;
  bool showRequest = false;
  bool showSummary = false;

  // Map
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;

  // Summary animation
  late final AnimationController _summaryAnimController;
  late final Animation<double> _summaryExpandAnim;
  late final Animation<double> _summaryFadeAnim;

  // Mock data — Atendimentos Recentes
  static const List<Map<String, String>> _recentServices = [
    {'service': 'Instalação Elétrica', 'time': '09:30', 'value': 'R\$ 85,00', 'icon': 'bolt'},
    {'service': 'Reparo Hidráulico', 'time': '11:15', 'value': 'R\$ 65,00', 'icon': 'wrench'},
    {'service': 'Pintura Residencial', 'time': '14:00', 'value': 'R\$ 100,00', 'icon': 'paint'},
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _summaryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _summaryExpandAnim = CurvedAnimation(
      parent: _summaryAnimController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _summaryFadeAnim = CurvedAnimation(
      parent: _summaryAnimController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      reverseCurve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _summaryAnimController.dispose();
    super.dispose();
  }

  void _toggleSummary() {
    setState(() {
      showSummary = !showSummary;
      if (showSummary) {
        _summaryAnimController.forward();
      } else {
        _summaryAnimController.reverse();
      }
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

          // 2. Offline Dashboard
          if (!isOnline)
            const Positioned.fill(
              child: OfflineDashboard(),
            ),

          // 3. Top Action Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => _buildIconButton(
                      Icons.menu,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  if (isOnline) _buildEarningsBadge(),
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

          // 3.5 Animated Summary Panel
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 0,
            right: 0,
            child: _buildSummaryPanel(),
          ),

          // 4. Bottom Controls
          if (!showRequest)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomControls(),
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
  }

  Widget _buildMap() {
    if (_isLoadingLocation) {
      return Container(
        color: context.colors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: context.colors.themePrimary),
              SizedBox(height: 16),
              Text(
                'Carregando mapa...',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
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

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: _currentPosition!, initialZoom: 16),
      children: [
        TileLayer(
          urlTemplate: urlTemplate,
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.flutter_tcc',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _currentPosition!,
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? context.colors.textPrimary.withOpacity(0.2)
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
                        decoration: BoxDecoration(
                          color: context.colors.background,
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
                          color: context.colors.textPrimary,
                          width: 3,
                        ),
                      ),
                      child: const ProfileAvatar(
                        size: 56,
                        imageUrl:
                            'https://github.com/filiperotherds.png', // Opcional para mostrar a imagem
                        fallbackName: 'Você',
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
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.border,
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: context.colors.textPrimary),
        onPressed: onPressed ?? () {},
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: showSummary
                ? context.colors.themePrimary.withOpacity(0.5)
                : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.wallet,
              color: context.colors.themePrimary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'R\$ 250,00',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: showSummary ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                LucideIcons.chevron_down,
                color: context.colors.textSecondary,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    final colors = context.colors;
    return SizeTransition(
      sizeFactor: _summaryExpandAnim,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _summaryFadeAnim,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Icon(LucideIcons.clock, color: colors.themePrimary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Atendimentos Recentes',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_recentServices.length} serviços',
                          style: TextStyle(
                            color: colors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.border.withOpacity(0.5)),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _recentServices.length,
                  separatorBuilder: (_, _2) => Divider(
                    height: 1,
                    indent: 72,
                    color: colors.border.withOpacity(0.3),
                  ),
                  itemBuilder: (context, index) {
                    final item = _recentServices[index];
                    return _buildServiceCard(colors, item, index);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(AppColorsTheme colors, Map<String, String> item, int index) {
    final iconMap = {
      'bolt': LucideIcons.zap,
      'wrench': LucideIcons.wrench,
      'paint': LucideIcons.paintbrush,
    };
    final colorPalette = [colors.warning, colors.themePrimary, colors.success];
    final iconData = iconMap[item['icon']] ?? LucideIcons.briefcase;
    final iconColor = colorPalette[index % colorPalette.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['service'] ?? '',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 12, color: colors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        item['time'] ?? '',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item['value'] ?? '',
                style: TextStyle(
                  color: colors.success,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          if (isOnline)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingButton(Icons.help_outline, onPressed: () {}),
                _buildFloatingButton(Icons.my_location, onPressed: _centerMap),
              ],
            ),
          _buildMainToggleButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.textPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: IconButton(
        iconSize: 20,
        icon: Icon(icon, color: context.colors.textPrimary),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildMainToggleButton() {
    return GestureDetector(
      onTap: toggleOnline,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: isOnline ? 20 : 0),
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isOnline
              ? context.colors.themePrimary
              : context.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOnline
                ? Colors.transparent
                : context.colors.border,
            width: 1,
          ),
        ),
        child: isOnline
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.power,
                    color: context.colors.onPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: context.colors.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.power_off,
                    color: context.colors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offline',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
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
              border: Border.all(
                color: context.colors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const ProfileAvatar(
                  size: 48,
                  fallbackName: 'José da Silva',
                ),
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
              border: Border.all(
                color: context.colors.border,
                width: 1,
              ),
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
