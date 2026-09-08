import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/auth_error_card.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: AppSize.iconButton + AppSpacing.md + AppSpacing.xs,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppCircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Voltar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('Entrar'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.md,
                      AppSpacing.screenH,
                      AppSpacing.xl,
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state is AuthFailure) ...[
                              AuthErrorCard(
                                title: 'Falha ao entrar',
                                message: state.message,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                            Text(
                              'Acesse sua conta',
                              style: AppTypography.h1.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Entre para acompanhar seu trabalho e gerenciar seu negócio',
                              style: AppTypography.body.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            const Expanded(child: LoginForm()),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
