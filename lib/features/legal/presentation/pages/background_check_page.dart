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
import 'package:flutter_tcc/features/legal/data/models/account_verification.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';
import 'package:flutter_tcc/injection_container.dart';

/// Certidão de antecedentes criminais — o que se pede de quem vai entrar na
/// casa de alguém.
///
/// A certidão é emitida de graça pela internet; o app pede a foto dela e a data
/// de emissão. A revisão confere o conteúdo; o servidor já recusa arquivo que
/// não é imagem e certidão com mais de 90 dias.
class BackgroundCheckPage extends StatefulWidget {
  const BackgroundCheckPage({super.key});

  @override
  State<BackgroundCheckPage> createState() => _BackgroundCheckPageState();
}

class _BackgroundCheckPageState extends State<BackgroundCheckPage> {
  static const _maxAgeDays = 90;

  final _dataSource = sl<LegalRemoteDataSource>();
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _issuedAt = TextEditingController();
  final _dateMask = BrMasks.date();

  BackgroundCheckInfo? _info;
  XFile? _photo;
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
    _issuedAt.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final info = await _dataSource.getBackgroundCheck();
      if (!mounted) return;
      setState(() {
        _info = info;
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

  String? _validateDate(String? value) {
    final date = parseBrDate(value);
    if (date == null) return 'Informe a data de emissão';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.isAfter(today)) return 'A data não pode estar no futuro';
    if (today.difference(date).inDays > _maxAgeDays) {
      return 'A certidão precisa ter sido emitida nos últimos $_maxAgeDays dias';
    }
    return null;
  }

  Future<void> _pick() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Fotografar a certidão'),
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
    if (source == null) return;

    final photo = await _picker.pickImage(
      source: source,
      maxWidth: 2400,
      imageQuality: 85,
    );
    if (photo != null && mounted) setState(() => _photo = photo);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final photo = _photo;
    if (photo == null) {
      setState(() => _error = 'Fotografe a certidão para enviar');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final info = await _dataSource.submitBackgroundCheck(
        filePath: photo.path,
        issuedAt: parseBrDate(_issuedAt.text)!,
      );
      if (!mounted) return;
      setState(() {
        _info = info;
        _photo = null;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            info.status == IdentityStatus.approved
                ? 'Certidão aprovada.'
                : 'Certidão enviada. Avisamos quando a revisão terminar.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;

    return Scaffold(
      appBar: const AppBackAppBar(
        title: 'Certidão de antecedentes',
        subtitle: 'Exigida de quem presta serviço.',
      ),
      body: _loading && info == null
          ? const AppLoaderCentered()
          : info == null
          ? AppEmptyState(
              icon: LucideIcons.triangle_alert,
              title: 'Não foi possível carregar',
              description: _error,
              actionLabel: 'Tentar de novo',
              onAction: _load,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.md,
                AppSpacing.screenH,
                AppSpacing.xxl,
              ),
              children: [
                if (info.status != IdentityStatus.notSubmitted) ...[
                  _StatusCard(info: info),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (info.canSubmit) _buildForm(),
              ],
            ),
    );
  }

  Widget _buildForm() {
    final colors = context.colors;
    final photo = _photo;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            tone: AppCardTone.sunken,
            child: Text(
              'Emita de graça pela internet a certidão da Polícia Federal '
              '(gov.br/pf) ou a do Tribunal de Justiça do seu estado. Vale a '
              'emitida nos últimos $_maxAgeDays dias.',
              style: AppTypography.body.copyWith(color: colors.textBody),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _issuedAt,
            label: 'Data de emissão',
            hint: 'dd/mm/aaaa',
            keyboardType: TextInputType.number,
            inputFormatters: [_dateMask],
            validator: _validateDate,
          ),
          const SizedBox(height: AppSpacing.gap),
          Text(
            'Foto da certidão',
            style: AppTypography.label.copyWith(color: colors.textBody),
          ),
          const SizedBox(height: 6),
          AppCard(
            onTap: _submitting ? null : _pick,
            padding: EdgeInsets.zero,
            child: photo == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.camera,
                          size: 24,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Toque para fotografar',
                          style: AppTypography.label.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: AppRadius.lgAll,
                    child: Image.file(
                      File(photo.path),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(color: colors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'Enviar certidão',
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.info});

  final BackgroundCheckInfo info;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (icon, color, support) = switch (info.status) {
      IdentityStatus.approved => (
        LucideIcons.badge_check,
        colors.success,
        'Tudo certo com a sua certidão.',
      ),
      IdentityStatus.pending => (
        LucideIcons.clock,
        colors.info,
        'A revisão costuma levar até 1 dia útil.',
      ),
      IdentityStatus.rejected => (
        LucideIcons.triangle_alert,
        colors.error,
        info.rejectionReason ?? 'Envie uma nova certidão.',
      ),
      IdentityStatus.notSubmitted => (
        LucideIcons.file_text,
        colors.textSecondary,
        '',
      ),
    };

    return AppCard(
      tone: info.status == IdentityStatus.approved
          ? AppCardTone.brandSoft
          : AppCardTone.plain,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.status.certificateLabel,
                  style: AppTypography.title.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  support,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textBody,
                  ),
                ),
                if (info.issuedAt != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Emitida em ${formatBrDate(info.issuedAt!)}',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
