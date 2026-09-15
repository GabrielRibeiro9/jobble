import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';

/// Criação da organização, já com o tipo legal.
///
/// Autônomo ou empresa decide quem é a parte nos contratos, então é pedido
/// aqui e não escondido numa tela de configurações. Os demais dados legais
/// (endereço, qualificação, identidade) ficam para a central de cadastro.
class SignupStepProfile extends StatelessWidget {
  const SignupStepProfile({
    super.key,
    required this.formKey,
    required this.orgNameController,
    required this.descriptionController,
    required this.legalType,
    required this.onLegalTypeChanged,
    required this.documentController,
    required this.legalNameController,
    required this.cnpjMask,
    required this.onFinish,
    this.isLoading = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController orgNameController;
  final TextEditingController descriptionController;
  final OrganizationLegalType legalType;
  final ValueChanged<OrganizationLegalType> onLegalTypeChanged;
  final TextEditingController documentController;
  final TextEditingController legalNameController;
  final MaskTextInputFormatter cnpjMask;
  final VoidCallback onFinish;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompany = legalType == OrganizationLegalType.company;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Crie sua organização',
                    style: AppTypography.h1.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'É o nome que os clientes veem e o que aparece nos seus '
                    'contratos.',
                    style: AppTypography.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  AppTextField(
                    controller: orgNameController,
                    label: 'Nome da organização',
                    hint: 'Ex: Jobble Elétrica',
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v ?? '').trim().length < 2
                        ? 'Informe o nome da organização'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  AppTextField(
                    controller: descriptionController,
                    label: 'Descrição (opcional)',
                    hint: 'Descreva os serviços da sua organização',
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Como você atua?',
                    style: AppTypography.label.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (final type in OrganizationLegalType.values) ...[
                    AppSelectableCard(
                      title: type.label,
                      subtitle: type == OrganizationLegalType.individual
                          ? 'Os contratos saem no seu nome, com seu CPF'
                          : 'Os contratos saem no nome da empresa',
                      selected: legalType == type,
                      onTap: () => onLegalTypeChanged(type),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  if (isCompany) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: documentController,
                      label: 'CNPJ',
                      keyboardType: TextInputType.number,
                      inputFormatters: [cnpjMask],
                      validator: BrValidators.cnpj,
                    ),
                    const SizedBox(height: AppSpacing.gap),
                    AppTextField(
                      controller: legalNameController,
                      label: 'Razão social',
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          BrValidators.required(v, 'Informe a razão social'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Text.rich(
                    TextSpan(
                      text: 'Ao continuar, você concorda com os ',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Termos de Uso',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const TextSpan(text: ' e a '),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const TextSpan(text: ' do aplicativo.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'Finalizar',
            isLoading: isLoading,
            onPressed: onFinish,
          ),
        ],
      ),
    );
  }
}
