import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';

/// Primeiro passo do cadastro: quem é a pessoa e como ela entra.
///
/// CPF, nascimento e telefone vêm já aqui porque todo contrato começa pela
/// qualificação de quem assina. Pedir no cadastro evita que o profissional só
/// descubra que faltam dados na hora de fechar o primeiro serviço.
class SignupStepEmail extends StatelessWidget {
  const SignupStepEmail({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.cpfController,
    required this.birthDateController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.cpfMask,
    required this.birthDateMask,
    required this.phoneMask,
    required this.onContinue,
    this.isLoading = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController cpfController;
  final TextEditingController birthDateController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final MaskTextInputFormatter cpfMask;
  final MaskTextInputFormatter birthDateMask;
  final MaskTextInputFormatter phoneMask;
  final VoidCallback onContinue;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
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
                  AppTextField(
                    controller: nameController,
                    label: 'Nome completo',
                    hint: 'Como está no seu documento',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: BrValidators.fullName,
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  AppTextField(
                    controller: cpfController,
                    label: 'CPF',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [cpfMask],
                    validator: BrValidators.cpf,
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  AppTextField(
                    controller: birthDateController,
                    label: 'Data de nascimento',
                    hint: 'dd/mm/aaaa',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [birthDateMask],
                    validator: BrValidators.adultBirthDate,
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  AppTextField(
                    controller: phoneController,
                    label: 'Celular',
                    hint: '(11) 98765-4321',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [phoneMask],
                    autofillHints: const [AutofillHints.telephoneNumber],
                    validator: BrValidators.phone,
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  AppTextField(
                    controller: emailController,
                    label: 'E-mail',
                    hint: 'exemplo@email.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) => (value ?? '').contains('@')
                        ? null
                        : 'E-mail inválido',
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  AppTextField(
                    controller: passwordController,
                    label: 'Senha',
                    hint: 'Sua senha',
                    helper: 'Pelo menos 8 caracteres',
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => (value ?? '').length < 8
                        ? 'A senha precisa de 8 caracteres'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  AppTextField(
                    controller: confirmPasswordController,
                    label: 'Confirmar senha',
                    hint: 'Confirme sua senha',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => isLoading ? null : onContinue(),
                    validator: (value) => value != passwordController.text
                        ? 'As senhas não coincidem'
                        : null,
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
      ),
    );
  }
}
