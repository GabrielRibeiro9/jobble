import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/features/contracts/presentation/bloc/contract_detail_cubit.dart';
import 'package:flutter_tcc/features/contracts/presentation/widgets/contract_widgets.dart';

/// Revisão e assinatura.
///
/// O documento inteiro fica acima do botão de propósito: assinar sem rolar
/// pelo texto é possível, mas a tela não facilita. Se o contrato mudar
/// enquanto a pessoa lê (o servidor devolve 409), o cubit recarrega, o texto
/// novo aparece e o aceite volta a ficar desmarcado.
class SignContractPage extends StatefulWidget {
  const SignContractPage({super.key});

  @override
  State<SignContractPage> createState() => _SignContractPageState();
}

class _SignContractPageState extends State<SignContractPage> {
  bool _agreed = false;
  String? _hash;

  @override
  void initState() {
    super.initState();
    _hash = context.read<ContractDetailCubit>().state.contract?.contentHash;
  }

  Future<void> _sign() async {
    final signed = await context.read<ContractDetailCubit>().sign();
    if (signed && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<ContractDetailCubit, ContractDetailState>(
      listenWhen: (previous, current) =>
          previous.contract?.contentHash != current.contract?.contentHash,
      listener: (context, state) {
        setState(() {
          _hash = state.contract?.contentHash;
          _agreed = false;
        });
      },
      builder: (context, state) {
        final contract = state.contract;
        if (contract == null) return const SizedBox.shrink();

        return Scaffold(
          appBar: const AppBackAppBar(title: 'Assinar contrato'),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.md,
                    AppSpacing.screenH,
                    AppSpacing.xl,
                  ),
                  children: [
                    ContractDocumentView(document: contract.document),
                    if (_hash != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Versão ${contract.version} · código de verificação $_hash',
                        style: AppTypography.caption.copyWith(
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.xs,
                    AppSpacing.screenH,
                    AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        value: _agreed,
                        onChanged: (value) =>
                            setState(() => _agreed = value ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Li e concordo com todos os termos deste contrato.',
                          style: AppTypography.body.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        'A assinatura eletrônica registra data, hora, endereço IP '
                        'e o código de verificação deste documento.',
                        style: AppTypography.caption.copyWith(
                          color: colors.textHint,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppPrimaryButton(
                        label: 'Assinar contrato',
                        isLoading: state.acting,
                        onPressed: _agreed ? _sign : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
