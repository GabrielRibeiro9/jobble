import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class HomeBottomSheet extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggleOnline;

  const HomeBottomSheet({
    super.key,
    required this.isOnline,
    required this.onToggleOnline,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.15, 0.5, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle and Header
              _buildHeader(context),

              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  children: [
                    // Main Action Button (Uber-style)
                    _buildMainActionButton(context),

                    const SizedBox(height: 32),

                    // Additional Menu Items
                    _buildMenuItem(LucideIcons.user, 'Perfil e Conta'),
                    _buildMenuItem(LucideIcons.history, 'Histórico de Viagens'),
                    _buildMenuItem(LucideIcons.wallet, 'Pagamentos'),
                    _buildMenuItem(LucideIcons.shield_question_mark, 'Ajuda'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Handle
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Icon (Settings/Sliders)
              const Icon(
                LucideIcons.sliders_horizontal,
                color: Colors.black,
                size: 28,
              ),

              // Center Text
              Text(
                isOnline ? 'You\'re online' : 'You\'re offline',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.8,
                ),
              ),

              // Right Icon (List)
              const Icon(LucideIcons.list, color: Colors.black, size: 28),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 1.5, color: Color(0xFFF5F5F5)),
      ],
    );
  }

  Widget _buildMainActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onToggleOnline,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOnline ? Colors.red : const Color(0xFF2EB086),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(isOnline ? 'GO OFFLINE' : 'GO ONLINE'),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          const Icon(LucideIcons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
