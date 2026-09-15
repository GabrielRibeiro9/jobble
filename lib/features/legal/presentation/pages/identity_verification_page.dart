import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';
import 'package:flutter_tcc/features/legal/data/datasources/legal_remote_data_source.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/legal_profile_page.dart';
import 'package:flutter_tcc/injection_container.dart';

/// Verificação de identidade: foto do documento e selfie segurando o
/// documento.
///
/// O servidor confere as imagens contra o cadastro (nome, CPF, nascimento),
/// então esses dados precisam estar preenchidos antes — a tela manda para os
/// dados pessoais quando não estão.
class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  final _dataSource = sl<LegalRemoteDataSource>();
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _issuer = TextEditingController();

  IdentityDocumentType _type = IdentityDocumentType.rg;
  XFile? _front;
  XFile? _back;
  XFile? _selfie;

  UserLegalProfile? _profile;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _number.dispose();
    _issuer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final profile = await _dataSource.getUserProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  /// A verificação compara a foto com o cadastro; sem estes três dados não há
  /// com o que comparar.
  bool get _hasBasics {
    final profile = _profile;
    if (profile == null) return false;
    return BrValidators.fullName(profile.name) == null &&
        isValidCpf(profile.cpf) &&
        profile.birthDate != null;
  }

  Future<XFile?> _pick({required bool selfie}) async {
    ImageSource? source = ImageSource.camera;

    // Documento pode vir da galeria (muita gente já tem a foto); selfie, não —
    // o sentido dela é ser tirada agora.
    if (!selfie) {
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null) return null;
    }

    return _picker.pickImage(
      source: source,
      preferredCameraDevice: selfie ? CameraDevice.front : CameraDevice.rear,
      maxWidth: 2000,
      imageQuality: 85,
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final missingPhoto = _front == null
        ? 'Tire a foto da frente do documento'
        : _type.needsBack && _back == null
        ? 'Tire a foto do verso do RG'
        : _selfie == null
        ? 'Tire a selfie segurando o documento'
        : null;

    if (missingPhoto != null) {
      _showError(missingPhoto);
      return;
    }

    setState(() => _submitting = true);

    try {
      final status = await _dataSource.submitIdentity(
        documentType: _type,
        documentNumber: _number.text.trim(),
        documentIssuer: _type == IdentityDocumentType.rg ? _issuer.text : null,
        frontPath: _front!.path,
        backPath: _type.needsBack ? _back!.path : null,
        selfiePath: _selfie!.path,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == IdentityStatus.approved
                ? 'Identidade verificada'
                : 'Documentos enviados. Avisaremos quando a análise terminar',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showError(error.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: context.colors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      appBar: const AppBackAppBar(title: 'Verificação de identidade'),
      body: _loading
          ? const AppLoaderCentered()
          : profile == null
          ? AppEmptyState(
              icon: LucideIcons.triangle_alert,
              title: 'Não foi possível carregar',
              description: _error,
              actionLabel: 'Tentar de novo',
              onAction: _load,
            )
          : switch (profile.identityStatus) {
              IdentityStatus.approved => const AppEmptyState(
                icon: LucideIcons.shield_check,
                title: 'Identidade verificada',
                description: 'Você já pode enviar e assinar contratos.',
              ),
              IdentityStatus.pending => const AppEmptyState(
                icon: LucideIcons.clock,
                title: 'Em análise',
                description:
                    'Recebemos seus documentos. Avisaremos assim que a revisão '
                    'terminar.',
              ),
              _ when !_hasBasics => AppEmptyState(
                icon: LucideIcons.user,
                title: 'Complete seus dados primeiro',
                description:
                    'A verificação compara o documento com seu nome completo, '
                    'CPF e data de nascimento.',
                actionLabel: 'Preencher dados pessoais',
                onAction: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LegalProfilePage()),
                  );
                  if (mounted) _load();
                },
              ),
              _ => _buildForm(profile),
            },
    );
  }

  Widget _buildForm(UserLegalProfile profile) {
    final colors = context.colors;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.md,
          AppSpacing.screenH,
          AppSpacing.xxl,
        ),
        children: [
          if (profile.identityStatus == IdentityStatus.rejected) ...[
            AppCard(
              bordered: true,
              child: Text(
                'Sua última verificação foi recusada'
                '${profile.identityRejectionReason != null ? ': ${profile.identityRejectionReason}' : '.'} '
                'Envie de novo com fotos nítidas.',
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            'Qual documento você vai usar?',
            style: AppTypography.h3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final type in IdentityDocumentType.values) ...[
            AppSelectableCard(
              title: type.label,
              subtitle: type.needsBack
                  ? 'Frente e verso'
                  : 'Só a frente (a página com a foto)',
              selected: _type == type,
              onTap: () => setState(() => _type = type),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _number,
            label: 'Número do ${_type.label}',
            textInputAction: TextInputAction.next,
            validator: (v) => BrValidators.required(v, 'Informe o número'),
          ),
          if (_type == IdentityDocumentType.rg) ...[
            const SizedBox(height: AppSpacing.gap),
            AppTextField(
              controller: _issuer,
              label: 'Órgão emissor / UF',
              hint: 'Ex.: SSP/SP',
              validator: (v) =>
                  BrValidators.required(v, 'Informe o órgão emissor'),
            ),
          ],
          const SizedBox(height: AppSpacing.section),
          Text(
            'Fotos',
            style: AppTypography.h3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Boa luz, sem reflexo e com o documento inteiro na foto. Na selfie, '
            'seu rosto e o documento precisam aparecer.',
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _PhotoTile(
            label: 'Frente do documento',
            file: _front,
            onTap: () async {
              final file = await _pick(selfie: false);
              if (file != null) setState(() => _front = file);
            },
          ),
          if (_type.needsBack) ...[
            const SizedBox(height: AppSpacing.xs),
            _PhotoTile(
              label: 'Verso do documento',
              file: _back,
              onTap: () async {
                final file = await _pick(selfie: false);
                if (file != null) setState(() => _back = file);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          _PhotoTile(
            label: 'Selfie segurando o documento',
            file: _selfie,
            icon: LucideIcons.scan_face,
            onTap: () async {
              final file = await _pick(selfie: true);
              if (file != null) setState(() => _selfie = file);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'As imagens são usadas só para confirmar sua identidade e ficam em '
            'área privada. Enviar de novo apaga as anteriores.',
            style: AppTypography.caption.copyWith(color: colors.textHint),
          ),
          const SizedBox(height: AppSpacing.section),
          AppPrimaryButton(
            label: 'Enviar para verificação',
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.label,
    required this.file,
    required this.onTap,
    this.icon = LucideIcons.id_card,
  });

  final String label;
  final XFile? file;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      onTap: onTap,
      bordered: file == null,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: SizedBox.square(
              dimension: 56,
              child: file == null
                  ? ColoredBox(
                      color: colors.surfaceLight,
                      child: Icon(icon, color: colors.textSecondary),
                    )
                  : Image.file(File(file!.path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.title.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  file == null ? 'Toque para tirar a foto' : 'Toque para trocar',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            file == null ? LucideIcons.camera : LucideIcons.circle_check,
            color: file == null ? colors.textHint : colors.success,
          ),
        ],
      ),
    );
  }
}
