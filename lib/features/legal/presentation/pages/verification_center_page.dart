import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/legal/data/datasources/legal_remote_data_source.dart';
import 'package:flutter_tcc/features/legal/data/models/account_verification.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/background_check_page.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/identity_verification_page.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/legal_profile_page.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/organization_legal_page.dart';
import 'package:flutter_tcc/features/legal/presentation/widgets/readiness_card.dart';
import 'package:flutter_tcc/features/onboard/presentation/pages/intro_page.dart';
import 'package:flutter_tcc/injection_container.dart';

/// Central de verificação: dados pessoais, dados da organização, identidade e
/// certidão de antecedentes, com a situação da conta no topo.
///
/// Tem dois papéis. Como porta de entrada ([asGate]) é o que o profissional vê
/// até a conta ser liberada — sem voltar, com saída da conta. Fora dela, é o
/// destino de todo "complete seu cadastro" do app.
class VerificationCenterPage extends StatefulWidget {
  const VerificationCenterPage({super.key, this.asGate = false, this.onChanged});

  final bool asGate;

  /// Chamado depois de cada etapa: a porta de entrada reavalia a conta.
  final VoidCallback? onChanged;

  @override
  State<VerificationCenterPage> createState() => _VerificationCenterPageState();
}

class _VerificationCenterPageState extends State<VerificationCenterPage> {
  final _dataSource = sl<LegalRemoteDataSource>();

  UserLegalProfile? _user;
  OrganizationLegalProfile? _organization;
  BackgroundCheckInfo? _background;
  AccountVerification? _verification;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<Object>([
        _dataSource.getUserProfile(),
        _dataSource.getOrganizationProfile(),
        _dataSource.getBackgroundCheck(),
        _dataSource.getAccountVerification(),
      ]);
      if (!mounted) return;
      setState(() {
        _user = results[0] as UserLegalProfile;
        _organization = results[1] as OrganizationLegalProfile;
        _background = results[2] as BackgroundCheckInfo;
        _verification = results[3] as AccountVerification;
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

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    await _load();
    widget.onChanged?.call();
  }

  void _signOut() {
    context.read<AuthBloc>().add(LogoutRequested());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IntroPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = _user;
    final organization = _organization;
    final background = _background;
    final verification = _verification;
    final loaded =
        user != null &&
        organization != null &&
        background != null &&
        verification != null;

    return Scaffold(
      appBar: widget.asGate
          ? AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Verificação da conta'),
              actions: [
                TextButton(onPressed: _signOut, child: const Text('Sair')),
                const SizedBox(width: AppSpacing.xs),
              ],
            )
          : const AppBackAppBar(
              title: 'Cadastro e verificação',
              subtitle: 'Segurança para as duas partes.',
            ),
      body: _loading && !loaded
          ? const AppLoaderCentered()
          : !loaded
          ? AppEmptyState(
              icon: LucideIcons.triangle_alert,
              title: 'Não foi possível carregar',
              description: _error,
              actionLabel: 'Tentar de novo',
              onAction: _load,
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _load();
                widget.onChanged?.call();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.md,
                  AppSpacing.screenH,
                  AppSpacing.xxl,
                ),
                children: [
                  Text(
                    widget.asGate
                        ? 'Antes de receber chamados, a Jobble confere quem '
                              'você é — como as plataformas de transporte fazem '
                              'com motoristas. Complete as etapas abaixo; a '
                              'revisão costuma levar até 1 dia útil.'
                        : 'Seus dados, documentos e a situação de cada '
                              'verificação. É o que dá segurança às duas partes '
                              'de um contrato.',
                    style: AppTypography.body.copyWith(color: colors.textBody),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ReadinessCard(
                    title: 'Situação da conta',
                    readiness: verification.readiness,
                    pendingIntro: widget.asGate
                        ? 'Para liberar a conta, falta:'
                        : 'Para receber chamados e assinar, falta:',
                  ),
                  const SizedBox(height: AppSpacing.section),
                  AppListGroup(
                    header: 'Etapas',
                    children: [
                      AppListRow(
                        title: 'Dados pessoais',
                        subtitle: user.readiness.missing.isEmpty
                            ? 'Completos'
                            : 'Falta: ${user.readiness.missing.join(', ')}',
                        icon: LucideIcons.user,
                        trailing: _doneIcon(user.readiness.missing.isEmpty),
                        onTap: () => _open(const LegalProfilePage()),
                      ),
                      AppListRow(
                        title: 'Dados da organização',
                        subtitle: organization.legalType.label,
                        icon: LucideIcons.building_2,
                        trailing: _doneIcon(
                          organization.legalType ==
                                  OrganizationLegalType.individual ||
                              (organization.document != null &&
                                  organization.address != null),
                        ),
                        onTap: () => _open(const OrganizationLegalPage()),
                      ),
                      AppListRow(
                        title: 'Verificação de identidade',
                        subtitle: user.identityStatus.label,
                        icon: LucideIcons.scan_face,
                        trailing: _doneIcon(
                          user.identityStatus == IdentityStatus.approved,
                        ),
                        onTap: () => _open(const IdentityVerificationPage()),
                      ),
                      AppListRow(
                        title: 'Certidão de antecedentes',
                        subtitle: background.status.certificateLabel,
                        icon: LucideIcons.shield_check,
                        trailing: _doneIcon(
                          background.status == IdentityStatus.approved,
                        ),
                        onTap: () => _open(const BackgroundCheckPage()),
                      ),
                    ],
                  ),
                  if (widget.asGate) ...[
                    const SizedBox(height: AppSpacing.xl),
                    if (verification.canWork)
                      AppPrimaryButton(
                        label: 'Entrar no Jobble',
                        onPressed: widget.onChanged,
                      )
                    else
                      AppSecondaryButton(
                        label: 'Atualizar situação',
                        onPressed: () async {
                          await _load();
                          widget.onChanged?.call();
                        },
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _doneIcon(bool done) {
    final colors = context.colors;
    return Icon(
      done ? LucideIcons.circle_check : LucideIcons.chevron_right,
      size: 18,
      color: done ? colors.success : colors.textHint,
    );
  }
}
