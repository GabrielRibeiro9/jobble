import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/otp_input.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';

class SignupStepOtp extends StatefulWidget {
  const SignupStepOtp({
    super.key,
    required this.email,
    required this.onContinue,
    this.isLoading = false,
  });

  final String email;
  final ValueChanged<String> onContinue;
  final bool isLoading;

  @override
  State<SignupStepOtp> createState() => _SignupStepOtpState();
}

class _SignupStepOtpState extends State<SignupStepOtp> {
  static const _codeLength = 6;
  String _code = '';

  bool get _isComplete => _code.length == _codeLength;

  void _resend() {
    context.read<AuthBloc>().add(
      ResendVerificationEmailRequested(email: widget.email),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código reenviado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código de verificação',
          style: AppTypography.h1.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Enviamos um código de $_codeLength dígitos para:',
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          widget.email,
          style: AppTypography.title.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.section),
        OtpInput(
          length: _codeLength,
          onChanged: (value) => setState(() => _code = value),
          onCompleted: widget.isLoading ? (_) {} : widget.onContinue,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: 'Validar código',
          isLoading: widget.isLoading,
          onPressed: _isComplete ? () => widget.onContinue(_code) : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: widget.isLoading ? null : _resend,
            child: const Text('Reenviar código'),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
