import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/profile/presentation/widgets/tag_input.dart';

class OrganizationSettingsPage extends StatefulWidget {
  const OrganizationSettingsPage({super.key});

  @override
  State<OrganizationSettingsPage> createState() =>
      _OrganizationSettingsPageState();
}

class _OrganizationSettingsPageState extends State<OrganizationSettingsPage> {
  final TextEditingController _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthSuccess && state.user?.organization != null) {
      final org = state.user!.organization!;
      _tags = _parseTags(org.tags);
      _bioController.text = org.bio ?? '';
    } else {
      _tags = [];
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    return raw
        .split(RegExp(r'[;,\s]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  String _tagsToString(List<String> tags) => tags.join('; ');

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        UpdateOrganizationProfileSubmitted(
          tags: _tagsToString(_tags),
          bio: _bioController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pop(context, true);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      child: Scaffold(
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
          title: const Text('Parâmetros'),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.xl,
                  AppSpacing.screenH,
                  AppSpacing.xl,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppFieldGroup(
                          label: 'Tags de serviços',
                          helper:
                              'Digite uma tag e pressione Enter para adicionar.',
                          child: TagInput(
                            tags: _tags,
                            onTagsChanged: (tags) {
                              setState(() => _tags = tags);
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _bioController,
                          label: 'Descrição profissional',
                          hint: 'Descreva os serviços da sua organização...',
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Adicione uma descrição';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppPrimaryButton(
                          label: 'Salvar',
                          isLoading: isLoading,
                          onPressed: _onSave,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
