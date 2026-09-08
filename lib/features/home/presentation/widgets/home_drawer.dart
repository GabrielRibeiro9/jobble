import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.inbox,
                    title: 'Pendentes',
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
                    title: 'Galeria',
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
                      MaterialPageRoute(
                        builder: (_) => const CertificatesPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: _buildMenuItem(
                context,
                icon: LucideIcons.circle_question_mark,
                title: 'Suporte',
                onTap: () {
                  // Handle support
                },
              ),
            ),
            _buildUserCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/images/logo-jobble-white.png'
        : 'assets/images/logo-jobble.png';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(logoAsset, height: 32, fit: BoxFit.contain),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? avatarUrl;
        String avatarFallback = '';
        String name = 'Convidado';
        String email = 'Entrar na sua conta';

        if (state is AuthSuccess && state.user != null) {
          final org = state.user!.organization;
          avatarUrl = org?.avatarUrl;
          avatarFallback = org?.name ?? '';
          name = org?.name ?? 'Usuário';
          email = state.user!.email;
        }

        return Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: context.colors.border,
              width: AppSize.border,
            ),
          ),
          child: Row(
            children: [
              ProfileAvatar(
                size: AppSize.categoryIcon,
                imageUrl: avatarUrl,
                fallbackName: avatarFallback,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevrons_up_down,
                color: context.colors.textSecondary,
                size: 16,
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
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      minLeadingWidth: 0,
      horizontalTitleGap: AppSpacing.sm,
      leading: Icon(icon, color: color ?? context.colors.textPrimary, size: 20),
      title: Text(
        title,
        style: AppTypography.title.copyWith(
          color: color ?? context.colors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }
}
