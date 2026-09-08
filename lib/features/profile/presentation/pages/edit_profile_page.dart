import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';
import 'package:flutter_tcc/injection_container.dart' as di;
import 'package:flutter_tcc/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_tcc/features/profile/presentation/pages/edit_field_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  final ProfileRemoteDataSource _dataSource = di.sl<ProfileRemoteDataSource>();
  bool _uploading = false;
  bool _picking = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_picking) return;
    _picking = true;

    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    _picking = false;
    if (xFile == null) return;

    setState(() => _uploading = true);

    try {
      final avatarUrl = await _dataSource.updateOrganizationAvatar(
        File(xFile.path),
      );
      if (!mounted) return;
      context.read<AuthBloc>().add(OrganizationAvatarUpdated(avatarUrl));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar foto: $e'),
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: AppSize.iconButton + AppSpacing.md + AppSpacing.xs,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppCircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Voltar',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('Editar perfil'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String? avatarUrl;
          String orgName = '';
          String userName = '';
          String email = '';

          if (state is AuthSuccess && state.user != null) {
            final user = state.user!;
            final org = user.organization;
            avatarUrl = org?.avatarUrl;
            orgName = org?.name ?? '';
            userName = user.name ?? '';
            email = user.email;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.section,
              AppSpacing.screenH,
              AppSpacing.section,
            ),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _uploading ? null : _showPickerOptions,
                  child: SizedBox(
                    width: 104,
                    height: 104,
                    child: Stack(
                      children: [
                        ProfileAvatar(
                          size: 104,
                          imageUrl: avatarUrl,
                          fallbackName: orgName,
                        ),
                        if (_uploading)
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: context.colors.overlay,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(child: AppLoader()),
                            ),
                          )
                        else
                          // Badge de edição em lima, encostado na borda do
                          // avatar: a única marca de acento da tela.
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.colors.background,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.photo_camera_rounded,
                                size: 16,
                                color: context.colors.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              AppListGroup(
                header: 'Dados da conta',
                children: [
                  AppListRow(
                    title: 'Organização',
                    value: orgName,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditFieldPage(
                            title: 'Editar organização',
                            fieldLabel: 'Nome da organização',
                            currentValue: orgName,
                            onSave: (value) async {
                              await _dataSource.updateOrganizationName(value);
                              if (!context.mounted) return;
                              context.read<AuthBloc>().add(UserRequested());
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  AppListRow(
                    title: 'Nome',
                    value: userName,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditFieldPage(
                            title: 'Editar nome',
                            fieldLabel: 'Nome',
                            currentValue: userName,
                            onSave: (value) async {
                              await _dataSource.updateUserName(value);
                              if (!context.mounted) return;
                              context.read<AuthBloc>().add(UserRequested());
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  AppListRow(title: 'E-mail', value: email),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
