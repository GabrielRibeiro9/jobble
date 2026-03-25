import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isOnline = false;
  bool showRequest = false;

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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Map Background Placeholder
          _buildMapPlaceholder(),

          // 2. Dark Overlay if offline
          if (!isOnline) Container(color: Colors.black.withOpacity(0.6)),

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
                  _buildIconButton(Icons.menu),
                  _buildStatusToggle(),
                  _buildIconButton(Icons.person, onPressed: () {}),
                ],
              ),
            ),
          ),

          // 4. Bottom Cards (Online / Offline status)
          if (!isOnline && !showRequest)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildOfflineBottomCard(),
            ),

          if (isOnline && !showRequest)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildOnlineBottomCard(),
            ),

          // 5. Incoming Request Overlay
          if (showRequest)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildIncomingRequestCard(),
            ),
        ],
      ),
      floatingActionButton: isOnline && !showRequest
          ? FloatingActionButton.extended(
              onPressed: simulateIncomingRequest,
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.notifications_active, color: Colors.white),
              label: const Text(
                'Simular Pedido',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surfaceLight),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Mapa / Sua localização',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  Widget _buildStatusToggle() {
    return GestureDetector(
      onTap: toggleOnline,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isOnline ? Colors.blueAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          isOnline ? 'ONLINE' : 'OFFLINE',
          style: TextStyle(
            color: isOnline ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineBottomCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bedtime, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text(
            'Você está offline',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fique online para receber solicitações de serviços.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SafeArea(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildOnlineBottomCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Ganhos (Hoje)',
                'R\$ 0,00',
                Icons.account_balance_wallet,
              ),
              _buildStatItem('Serviços', '0', Icons.assignment_turned_in),
              _buildStatItem('Avaliação', '5.0', Icons.star),
            ],
          ),
          const SafeArea(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildIncomingRequestCard() {
    return Container(
      margin: const EdgeInsets.all(16).copyWith(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.build,
                    color: Colors.blueAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nova Solicitação!',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Serviço de Encanador',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Conserto de vazamento - Urgente',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'A 2.5 km (Aprox. 10 min)',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const Text(
                  'R\$ 150,00',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: acceptOrRejectRequest,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'RECUSAR',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: acceptOrRejectRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ACEITAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
