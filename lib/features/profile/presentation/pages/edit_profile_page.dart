import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
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
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildPropertyRow(String title, String value, VoidCallback? onTap) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.border.withValues(alpha: 0.3)),
            bottom: BorderSide(color: colors.border.withValues(alpha: 0.3)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Perfil'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
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
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _uploading ? null : _showPickerOptions,
                  child: Stack(
                    children: [
                      ProfileAvatar(
                        size: 100,
                        imageUrl: avatarUrl,
                        fallbackName: orgName,
                      ),
                      if (!_uploading)
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0x66FFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.edit,
                                size: 28,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      if (_uploading)
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: AppLoader(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildPropertyRow(
                'Organização',
                orgName,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFieldPage(
                        title: 'Editar Organização',
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
              _buildPropertyRow('Email', email, null),
              _buildPropertyRow(
                'Nome',
                userName,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFieldPage(
                        title: 'Editar Nome',
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
            ],
          );
        },
      ),
    );
  }
}
