import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';
import 'package:flutter_tcc/core/widgets/star_rating.dart';
import 'package:flutter_tcc/features/schedule/presentation/pages/schedule_page.dart';
import 'package:flutter_tcc/features/services/presentation/pages/services_page.dart';
import 'package:flutter_tcc/features/gallery/presentation/pages/gallery_page.dart';
import 'package:flutter_tcc/features/wallet/presentation/pages/wallet_page.dart';
import 'package:flutter_tcc/features/reviews/presentation/pages/reviews_page.dart';
import 'package:flutter_tcc/features/certificates/presentation/pages/certificates_page.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.background,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: LucideIcons.calendar,
                  title: 'Minha Agenda',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SchedulePage()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: LucideIcons.briefcase,
                  title: 'Meus Serviços',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServicesPage()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: LucideIcons.image,
                  title: 'Galeria de Trabalhos',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GalleryPage()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: LucideIcons.wallet,
                  title: 'Carteira',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletPage()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: LucideIcons.star,
                  title: 'Avaliações',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReviewsPage()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: LucideIcons.award,
                  title: 'Certificados',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CertificatesPage()),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: LucideIcons.log_out,
            title: 'Sair',
            onTap: () {
              // Handle logout
            },
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? avatarUrl;
        String name = 'Convidado';

        if (state is AuthSuccess && state.user != null) {
          avatarUrl = state.user!.avatarUrl;
          name = state.user!.name ?? 'Usuário';
        }

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 24,
            left: 24,
            right: 24,
            bottom: 24,
          ),
          color: context.colors.surface,
          child: Row(
            children: [
              ProfileAvatar(
                size: 64,
                imageUrl: avatarUrl,
                fallbackName: name,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const StarRating(rating: 4.8, hiring: 124),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? context.colors.textPrimary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? context.colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }
}
