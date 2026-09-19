import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/config/app_config.dart';
import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/features/home/presentation/pages/main_shell_page.dart';
import 'package:flutter_tcc/features/legal/data/datasources/legal_remote_data_source.dart';
import 'package:flutter_tcc/features/legal/data/models/account_verification.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/verification_center_page.dart';
import 'package:flutter_tcc/injection_container.dart';

/// Porta de entrada depois do login: a conta só entra no app verificada.
///
/// Como nas plataformas de transporte, o profissional não recebe chamado
/// nenhum antes de a Jobble conferir quem ele é — cadastro completo,
/// identidade e certidão de antecedentes. Enquanto faltar algo, esta tela
/// mostra a central de verificação no lugar das abas.
class AccountGatePage extends StatefulWidget {
  const AccountGatePage({super.key});

  @override
  State<AccountGatePage> createState() => _AccountGatePageState();
}

class _AccountGatePageState extends State<AccountGatePage> {
  final _dataSource = sl<LegalRemoteDataSource>();

  AccountVerification? _verification;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final verification = await _dataSource.getAccountVerification();
      if (!mounted) return;
      setState(() {
        _verification = verification;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final verification = _verification;

    if (verification == null) {
      return Scaffold(
        body: _loading
            ? const AppLoaderCentered(label: 'Conferindo seu cadastro…')
            : AppEmptyState(
                icon: LucideIcons.triangle_alert,
                title: 'Não foi possível conferir seu cadastro',
                description: _error,
                actionLabel: 'Tentar de novo',
                onAction: _check,
              ),
      );
    }

    if (verification.canWork || AppConfig.skipVerification) {
      return const MainShellPage();
    }

    return VerificationCenterPage(asGate: true, onChanged: _check);
  }
}
