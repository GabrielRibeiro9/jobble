import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';

class SignupStepProfile extends StatelessWidget {
  final TextEditingController orgNameController;
  final TextEditingController descriptionController;
  final VoidCallback onFinish;
  final bool isLoading;

  const SignupStepProfile({
    super.key,
    required this.orgNameController,
    required this.descriptionController,
    required this.onFinish,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crie sua organização',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Dê um nome para sua empresa ou organização profissional',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Text(
          'Nome da organização',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: orgNameController,
          style: TextStyle(color: context.colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ex: Jobble Elétrica',
            filled: true,
            fillColor: context.colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderLight),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Descrição (opcional)',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          style: TextStyle(color: context.colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Descreva os serviços da sua organização',
            filled: true,
            fillColor: context.colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderLight),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text.rich(
          TextSpan(
            text: 'Ao continuar, você concorda com os ',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
            children: [
              TextSpan(
                text: 'Termos de Uso',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const TextSpan(text: ' e a '),
              TextSpan(
                text: 'Política de Privacidade',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const TextSpan(text: ' do aplicativo.'),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.7),
            ),
            child: isLoading
                ? const AppLoader()
                : Text(
                    'Finalizar',
                    style: TextStyle(
                      color: context.colors.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
