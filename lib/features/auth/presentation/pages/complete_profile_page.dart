import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_step_profile.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/account_gate_page.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _legalNameController = TextEditingController();
  final _cnpjMask = BrMasks.cnpj();
  final _formKey = GlobalKey<FormState>();

  OrganizationLegalType _legalType = OrganizationLegalType.individual;

  @override
  void dispose() {
    _orgNameController.dispose();
    _descriptionController.dispose();
    _documentController.dispose();
    _legalNameController.dispose();
    super.dispose();
  }

  void _onFinish() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final isCompany = _legalType == OrganizationLegalType.company;
    context.read<AuthBloc>().add(
      CompleteOnboardingSubmitted(
        organizationName: _orgNameController.text.trim(),
        description: _descriptionController.text,
        legalType: _legalType.apiValue,
        document: isCompany ? onlyDigits(_documentController.text) : null,
        legalName: isCompany ? _legalNameController.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOnboardingSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AccountGatePage()),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Completar perfil')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.xl,
              AppSpacing.screenH,
              AppSpacing.xl,
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return SignupStepProfile(
                  formKey: _formKey,
                  orgNameController: _orgNameController,
                  descriptionController: _descriptionController,
                  legalType: _legalType,
                  onLegalTypeChanged: (type) =>
                      setState(() => _legalType = type),
                  documentController: _documentController,
                  legalNameController: _legalNameController,
                  cnpjMask: _cnpjMask,
                  onFinish: _onFinish,
                  isLoading: isLoading,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
