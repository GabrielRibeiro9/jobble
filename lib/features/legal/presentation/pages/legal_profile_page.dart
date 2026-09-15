import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';
import 'package:flutter_tcc/features/legal/data/datasources/legal_remote_data_source.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';
import 'package:flutter_tcc/features/legal/presentation/widgets/legal_form_fields.dart';
import 'package:flutter_tcc/injection_container.dart';

/// Dados pessoais que um contrato precisa: a qualificação civil completa e o
/// endereço de residência.
///
/// Todos os campos, exceto o complemento, são obrigatórios: salvar pela
/// metade só adiaria para a hora de assinar a descoberta de que falta algo.
class LegalProfilePage extends StatefulWidget {
  const LegalProfilePage({super.key});

  @override
  State<LegalProfilePage> createState() => _LegalProfilePageState();
}

class _LegalProfilePageState extends State<LegalProfilePage> {
  final _dataSource = sl<LegalRemoteDataSource>();
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _cpf = TextEditingController();
  final _birth = TextEditingController();
  final _phone = TextEditingController();
  final _nationality = TextEditingController();
  final _profession = TextEditingController();
  final _zip = TextEditingController();
  final _street = TextEditingController();
  final _number = TextEditingController();
  final _complement = TextEditingController();
  final _neighborhood = TextEditingController();
  final _city = TextEditingController();

  final _cpfMask = BrMasks.cpf();
  final _birthMask = BrMasks.date();
  final _phoneMask = BrMasks.phone();
  final _zipMask = BrMasks.cep();

  MaritalStatus? _maritalStatus;
  String? _state;

  UserLegalProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _cpf,
      _birth,
      _phone,
      _nationality,
      _profession,
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
      final profile = await _dataSource.getUserProfile();
      if (!mounted) return;

      _name.text = profile.name ?? '';
      setMaskedText(_cpf, _cpfMask, profile.cpf);
      final birth = profile.birthDate;
      if (birth != null) {
        setMaskedText(
          _birth,
          _birthMask,
          formatBrDate(DateTime(birth.year, birth.month, birth.day)),
        );
      }
      setMaskedText(_phone, _phoneMask, profile.phone);
      _nationality.text = profile.nationality ?? 'brasileira';
      _profession.text = profile.profession ?? '';
      _maritalStatus = profile.maritalStatus;

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

    final locked = _profile?.verifiedDataLocked ?? false;
    final birth = parseBrDate(_birth.text)!;

    final body = <String, dynamic>{
      // Dado verificado não vai no corpo: o servidor recusaria a mudança, e
      // mandar o mesmo valor de volta não acrescenta nada.
      if (!locked) ...{
        'name': _name.text.trim(),
        'cpf': onlyDigits(_cpf.text),
        'birthDate': DateTime.utc(
          birth.year,
          birth.month,
          birth.day,
          12,
        ).toIso8601String(),
      },
      'phone': onlyDigits(_phone.text),
      'nationality': _nationality.text.trim(),
      'maritalStatus': _maritalStatus?.apiValue,
      'profession': _profession.text.trim(),
      'address': LegalAddress(
        street: _street.text.trim(),
        number: _number.text.trim(),
        complement: _complement.text.trim(),
        neighborhood: _neighborhood.text.trim(),
        city: _city.text.trim(),
        state: _state!,
        zipCode: onlyDigits(_zip.text),
      ).toJson(),
    };

    setState(() => _saving = true);

    try {
      await _dataSource.updateUserProfile(body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados salvos')),
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
      appBar: const AppBackAppBar(title: 'Dados pessoais'),
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
    final locked = _profile!.verifiedDataLocked;
    const lockedHelper = 'Verificado com seu documento — não pode ser alterado';

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
          Text(
            'Estes dados aparecem na qualificação das partes do contrato. '
            'Use os mesmos do seu documento de identidade.',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
          const FormSectionTitle('Identificação'),
          AppTextField(
            controller: _name,
            label: 'Nome completo',
            readOnly: locked,
            helper: locked ? lockedHelper : null,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            validator: BrValidators.fullName,
          ),
          const SizedBox(height: AppSpacing.gap),
          AppTextField(
            controller: _cpf,
            label: 'CPF',
            readOnly: locked,
            helper: locked ? lockedHelper : null,
            keyboardType: TextInputType.number,
            inputFormatters: [_cpfMask],
            validator: BrValidators.cpf,
          ),
          const SizedBox(height: AppSpacing.gap),
          AppTextField(
            controller: _birth,
            label: 'Data de nascimento',
            hint: 'dd/mm/aaaa',
            readOnly: locked,
            helper: locked ? lockedHelper : null,
            keyboardType: TextInputType.number,
            inputFormatters: [_birthMask],
            validator: BrValidators.adultBirthDate,
          ),
          const FormSectionTitle('Contato e qualificação'),
          AppTextField(
            controller: _phone,
            label: 'Telefone (com DDD)',
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMask],
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: BrValidators.phone,
          ),
          const SizedBox(height: AppSpacing.gap),
          AppTextField(
            controller: _nationality,
            label: 'Nacionalidade',
            textInputAction: TextInputAction.next,
            validator: (v) => BrValidators.required(v, 'Informe a nacionalidade'),
          ),
          const SizedBox(height: AppSpacing.gap),
          DropdownButtonFormField<MaritalStatus>(
            initialValue: _maritalStatus,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Estado civil'),
            items: [
              for (final status in MaritalStatus.values)
                DropdownMenuItem(value: status, child: Text(status.label)),
            ],
            onChanged: (value) => setState(() => _maritalStatus = value),
            validator: (v) => v == null ? 'Escolha o estado civil' : null,
          ),
          const SizedBox(height: AppSpacing.gap),
          AppTextField(
            controller: _profession,
            label: 'Profissão',
            textInputAction: TextInputAction.next,
            validator: (v) => BrValidators.required(v, 'Informe a profissão'),
          ),
          const FormSectionTitle('Endereço de residência'),
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
          const SizedBox(height: AppSpacing.section),
          AppPrimaryButton(
            label: 'Salvar dados',
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
