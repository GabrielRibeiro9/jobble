import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';

class SignupStepProfile extends StatelessWidget {
  const SignupStepProfile({
    super.key,
    required this.orgNameController,
    required this.descriptionController,
    required this.onFinish,
    this.isLoading = false,
  });

  final TextEditingController orgNameController;
  final TextEditingController descriptionController;
  final VoidCallback onFinish;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
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
                  'Dê um nome para sua empresa ou organização profissional.',
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
    );
  }
}
