import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

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
import 'package:flutter_tcc/features/legal/presentation/widgets/legal_form_fields.dart';
import 'package:flutter_tcc/injection_container.dart';

/// Como a organização aparece no contrato.
///
/// Autônomo assina em nome próprio — o contrato usa os dados pessoais do dono
/// e cita o nome comercial. Empresa é a parte do contrato, com CNPJ, razão
/// social e sede, e o dono assina como representante.
class OrganizationLegalPage extends StatefulWidget {
  const OrganizationLegalPage({super.key});

  @override
  State<OrganizationLegalPage> createState() => _OrganizationLegalPageState();
}

class _OrganizationLegalPageState extends State<OrganizationLegalPage> {
  final _dataSource = sl<LegalRemoteDataSource>();
  final _formKey = GlobalKey<FormState>();

  final _document = TextEditingController();
  final _legalName = TextEditingController();
  final _phone = TextEditingController();
  final _zip = TextEditingController();
  final _street = TextEditingController();
  final _number = TextEditingController();
  final _complement = TextEditingController();
  final _neighborhood = TextEditingController();
  final _city = TextEditingController();

  final _cnpjMask = BrMasks.cnpj();
  final _phoneMask = BrMasks.phone();
  final _zipMask = BrMasks.cep();

  OrganizationLegalType _legalType = OrganizationLegalType.individual;
  String? _state;

  OrganizationLegalProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isCompany => _legalType == OrganizationLegalType.company;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [
      _document,
      _legalName,
      _phone,
      _zip,
      _street,
      _number,
      _complement,
      _neighborhood,
      _city,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await _dataSource.getOrganizationProfile();
      if (!mounted) return;

      _legalType = profile.legalType;
      setMaskedText(_document, _cnpjMask, profile.document);
      _legalName.text = profile.legalName ?? '';
      setMaskedText(_phone, _phoneMask, profile.phone);

      final address = profile.address;
      if (address != null) {
        setMaskedText(_zip, _zipMask, address.zipCode);
        _street.text = address.street;
        _number.text = address.number;
        _complement.text = address.complement ?? '';
        _neighborhood.text = address.neighborhood;
        _city.text = address.city;
        _state = address.state;
      }

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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = onlyDigits(_phone.text);
    final body = <String, dynamic>{
      'legalType': _legalType.apiValue,
      'phone': phone.isEmpty ? null : phone,
      if (_isCompany) ...{
        'document': onlyDigits(_document.text),
        'legalName': _legalName.text.trim(),
        'address': LegalAddress(
          street: _street.text.trim(),
          number: _number.text.trim(),
          complement: _complement.text.trim(),
          neighborhood: _neighborhood.text.trim(),
          city: _city.text.trim(),
          state: _state!,
          zipCode: onlyDigits(_zip.text),
        ).toJson(),
      },
    };

    setState(() => _saving = true);

    try {
      await _dataSource.updateOrganizationProfile(body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados da organização salvos')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackAppBar(title: 'Dados da organização'),
      body: _loading
          ? const AppLoaderCentered()
          : _profile == null
          ? AppEmptyState(
              icon: LucideIcons.triangle_alert,
              title: 'Não foi possível carregar',
              description: _error,
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    final colors = context.colors;
    final canEdit = _profile!.canEdit;

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
          if (!canEdit) ...[
            AppCard(
              child: Text(
                'Só o responsável pela organização altera estes dados.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            'Como você atua?',
            style: AppTypography.h3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final type in OrganizationLegalType.values) ...[
            AppSelectableCard(
              title: type.label,
              subtitle: type == OrganizationLegalType.individual
                  ? 'O contrato sai no seu nome, com seu CPF'
                  : 'O contrato sai no nome da empresa; você assina como representante',
              selected: _legalType == type,
              onTap: () {
                if (canEdit) setState(() => _legalType = type);
              },
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (_isCompany) ...[
            const FormSectionTitle('Empresa'),
            AppTextField(
              controller: _document,
              label: 'CNPJ',
              enabled: canEdit,
              keyboardType: TextInputType.number,
              inputFormatters: [_cnpjMask],
              validator: BrValidators.cnpj,
            ),
            const SizedBox(height: AppSpacing.gap),
            AppTextField(
              controller: _legalName,
              label: 'Razão social',
              enabled: canEdit,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  BrValidators.required(v, 'Informe a razão social'),
            ),
          ],
          const FormSectionTitle('Contato comercial'),
          AppTextField(
            controller: _phone,
            label: 'Telefone (opcional)',
            enabled: canEdit,
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMask],
            validator: (v) =>
                onlyDigits(v).isEmpty ? null : BrValidators.phone(v),
          ),
          if (_isCompany) ...[
            const FormSectionTitle('Endereço da sede'),
            AddressFields(
              zipCode: _zip,
              zipMask: _zipMask,
              street: _street,
              number: _number,
              complement: _complement,
              neighborhood: _neighborhood,
              city: _city,
              state: _state,
              onStateChanged: (value) => setState(() => _state = value),
            ),
          ],
          if (canEdit) ...[
            const SizedBox(height: AppSpacing.section),
            AppPrimaryButton(
              label: 'Salvar',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ],
      ),
    );
  }
}
