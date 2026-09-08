import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/core/config/app_config.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';
import 'package:flutter_tcc/features/profile/data/models/project_model.dart';
import 'package:flutter_tcc/injection_container.dart' as di;
import 'package:flutter_tcc/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_tcc/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_tcc/features/profile/presentation/pages/organization_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRemoteDataSource _dataSource = di.sl<ProfileRemoteDataSource>();
  Future<List<ProjectModel>> _projectsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _projectsFuture = _dataSource.getProjects();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildProfileHeader()),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Editar perfil',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Parâmetros',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrganizationSettingsPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String matches = '0';
                String projects = '0';
                String rating = '0.0';

                if (state is AuthSuccess && state.user?.organization != null) {
                  final org = state.user!.organization!;
                  matches = org.matchesCount.toString();
                  projects = org.projectsCount.toString();
                  rating = org.rating.toStringAsFixed(1);
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat(matches, 'Matches'),
                    _buildStat(projects, 'Projetos'),
                    _buildStat(rating, 'Estrelas'),
                  ],
                );
              },
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(2),
          sliver: FutureBuilder<List<ProjectModel>>(
            future: _projectsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: AppLoader()),
                );
              }

              final projects = snapshot.data ?? [];

              if (projects.isEmpty) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: AppEmptyState(
                      icon: Icons.photo_library_outlined,
                      title: 'Nenhum projeto ainda',
                      description:
                          'Os trabalhos que você publicar aparecem aqui.',
                    ),
                  ),
                );
              }

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final project = projects[index];
                  final photoUrl = project.photoUrls.isNotEmpty
                      ? project.photoUrls.first
                      : null;
                  return GestureDetector(
                    onTap: () => _showProjectDetail(project),
                    child: photoUrl != null
                        ? Image.network(
                            AppConfig.uploadUrl(photoUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  );
                }, childCount: projects.length),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(color: context.colors.surfaceLight);
  }

  Widget _buildStat(String value, String label) {
    final colors = context.colors;
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.numeric.copyWith(
            color: colors.textPrimary,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? avatarUrl;
        String name = '';
        String email = '';

        if (state is AuthSuccess && state.user != null) {
          final org = state.user!.organization;
          avatarUrl = org?.avatarUrl;
          name = org?.name ?? '';
          email = state.user!.email;
        }

        final colors = context.colors;

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              ProfileAvatar(
                size: 88,
                imageUrl: avatarUrl,
                fallbackName: name,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                name,
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              // E-mail em pill de superfície: informação secundária, contida.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs + 2,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  email,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  void _showProjectDetail(ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final photoUrl = project.photoUrls.isNotEmpty
                ? project.photoUrls.first
                : null;
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photoUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.lgAll,
                        child: Image.network(
                          AppConfig.uploadUrl(photoUrl),
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 250,
                                color: context.colors.surfaceLight,
                              ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (project.title != null)
                          Text(
                            project.title!,
                            style: AppTypography.h2.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        if (project.completionDate != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            project.completionDate!,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                        if (project.description != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            project.description!,
                            style: AppTypography.body.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
