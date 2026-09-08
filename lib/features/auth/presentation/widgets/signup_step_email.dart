import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';

class SignupStepEmail extends StatelessWidget {
  const SignupStepEmail({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onContinue,
    this.isLoading = false,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onContinue;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'Nome completo',
                  hint: 'Seu nome',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: AppSpacing.gap),
                AppTextField(
                  controller: emailController,
                  label: 'E-mail',
                  hint: 'exemplo@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: AppSpacing.gap),
                AppTextField(
                  controller: passwordController,
                  label: 'Senha',
                  hint: 'Sua senha',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: AppSpacing.gap),
                AppTextField(
                  controller: confirmPasswordController,
                  label: 'Confirmar senha',
                  hint: 'Confirme sua senha',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => isLoading ? null : onContinue(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: 'Continuar',
          isLoading: isLoading,
          onPressed: onContinue,
        ),
      ],
    );
  }
}
