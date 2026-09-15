import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';

const brazilianStates = [
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG',
  'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE',
  'TO',
];

/// Preenche um campo mascarado sem dessincronizar a máscara: o formatador
/// guarda estado próprio, e escrever direto em `controller.text` o deixaria
/// achando que o campo está vazio na próxima edição.
void setMaskedText(
  TextEditingController controller,
  MaskTextInputFormatter mask,
  String? digits,
) {
  controller.value = mask.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(text: onlyDigits(digits)),
  );
}

/// Título de bloco dentro de um formulário longo.
class FormSectionTitle extends StatelessWidget {
  const FormSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.section,
        bottom: AppSpacing.md,
      ),
      child: Text(
        text,
        style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
      ),
    );
  }
}

/// Os campos de endereço, iguais para residência e sede.
class AddressFields extends StatelessWidget {
  const AddressFields({
    super.key,
    required this.zipCode,
    required this.zipMask,
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.onStateChanged,
  });

  final TextEditingController zipCode;
  final MaskTextInputFormatter zipMask;
  final TextEditingController street;
  final TextEditingController number;
  final TextEditingController complement;
  final TextEditingController neighborhood;
  final TextEditingController city;
  final String? state;
  final ValueChanged<String?> onStateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: zipCode,
          label: 'CEP',
          keyboardType: TextInputType.number,
          inputFormatters: [zipMask],
          validator: BrValidators.cep,
        ),
        const SizedBox(height: AppSpacing.gap),
        AppTextField(
          controller: street,
          label: 'Rua',
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.streetAddressLine1],
          validator: (v) => BrValidators.required(v, 'Informe a rua'),
        ),
        const SizedBox(height: AppSpacing.gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: number,
                label: 'Número',
                textInputAction: TextInputAction.next,
                validator: (v) => BrValidators.required(v, 'Informe o número'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: complement,
                label: 'Complemento (opcional)',
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gap),
        AppTextField(
          controller: neighborhood,
          label: 'Bairro',
          textInputAction: TextInputAction.next,
          validator: (v) => BrValidators.required(v, 'Informe o bairro'),
        ),
        const SizedBox(height: AppSpacing.gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                controller: city,
                label: 'Cidade',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.addressCity],
                validator: (v) => BrValidators.required(v, 'Informe a cidade'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: state,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'UF'),
                items: [
                  for (final uf in brazilianStates)
                    DropdownMenuItem(value: uf, child: Text(uf)),
                ],
                onChanged: onStateChanged,
                validator: (v) => v == null ? 'UF' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Só dígitos, para campos numéricos simples.
final digitsOnly = FilteringTextInputFormatter.digitsOnly;
