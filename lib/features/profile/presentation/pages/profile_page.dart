import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: context.colors.surfaceLight,
                      foregroundColor: context.colors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Editar Perfil'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const OrganizationSettingsPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: context.colors.surfaceLight,
                      foregroundColor: context.colors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Parâmetros'),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Nenhum projeto ainda',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
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
                            'http://10.0.2.2:3333/uploads/$photoUrl',
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
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
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

        return Container(
          color: context.colors.background,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ProfileAvatar(
                    size: 82,
                    imageUrl: avatarUrl,
                    fallbackName: name,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    email,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProjectDetail(ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
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
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (photoUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'http://10.0.2.2:3333/uploads/$photoUrl',
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (project.title != null)
                          Text(
                            project.title!,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (project.completionDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            project.completionDate!,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (project.description != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            project.description!,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 14,
                              height: 1.5,
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
