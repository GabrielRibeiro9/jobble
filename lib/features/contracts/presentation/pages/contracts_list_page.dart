import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/domain/contract_repository.dart';
import 'package:flutter_tcc/features/contracts/presentation/bloc/contracts_list_cubit.dart';
import 'package:flutter_tcc/features/contracts/presentation/pages/contract_detail_page.dart';
import 'package:flutter_tcc/features/contracts/presentation/widgets/contract_widgets.dart';
import 'package:flutter_tcc/injection_container.dart';

/// Todos os contratos da organização, com os que pedem ação em cima.
class ContractsListPage extends StatelessWidget {
  const ContractsListPage({super.key, this.embedded = false});

  /// Como aba da casca: sem AppBar própria (a casca já tem) e com espaço
  /// para a barra inferior no fim da lista.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ContractsListCubit(repository: sl<ContractRepository>())..load(),
      child: _ContractsListView(embedded: embedded),
    );
  }
}

class _ContractsListView extends StatelessWidget {
  const _ContractsListView({required this.embedded});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: embedded ? null : const AppBackAppBar(title: 'Contratos'),
      body: BlocBuilder<ContractsListCubit, ContractsListState>(
        builder: (context, state) {
          final cubit = context.read<ContractsListCubit>();

          if (state.loading && state.items.isEmpty) {
            return const AppLoaderCentered();
          }

          if (state.items.isEmpty) {
            return AppEmptyState(
              icon: LucideIcons.file_text,
              title: state.error != null
                  ? 'Não foi possível carregar'
                  : 'Nenhum contrato ainda',
              description:
                  state.error ??
                  'Quando um cliente escolher você, o contrato do serviço '
                      'aparece aqui.',
              actionLabel: state.error != null ? 'Tentar de novo' : null,
              onAction: state.error != null ? cubit.load : null,
            );
          }

          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.md,
                AppSpacing.screenH,
                embedded ? 120 : AppSpacing.xxl,
              ),
              children: [
                if (state.needingAttention.isNotEmpty) ...[
                  AppSectionHeader(
                    title: 'Pedem sua ação',
                    actionLabel: '${state.needingAttention.length}',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in state.needingAttention)
                    _ContractTile(item: item),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (state.others.isNotEmpty) ...[
                  const AppSectionHeader(title: 'Todos'),
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in state.others) _ContractTile(item: item),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContractTile extends StatelessWidget {
  const _ContractTile({required this.item});

  final ContractSummary item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        bordered: item.needsAttention,
        onTap: () async {
          final cubit = context.read<ContractsListCubit>();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContractDetailPage(contractId: item.id),
            ),
          );
          cubit.load();
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.clientName} · ${item.code}',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ContractStatusChip(status: item.status),
                ],
              ),
            ),
            if (item.priceCents != null)
              Text(
                formatCents(item.priceCents!),
                style: AppTypography.title.copyWith(color: colors.textPrimary),
              ),
          ],
        ),
      ),
    );
  }
}
