import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/utils/money_input_formatter.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/presentation/bloc/contract_detail_cubit.dart';
import 'package:flutter_tcc/features/legal/presentation/widgets/legal_form_fields.dart';

/// Garantia mínima aceita pelo backend (art. 26, II, do CDC).
const _minWarrantyDays = 90;

/// Os termos do contrato, editados pelo profissional.
///
/// Chegam pré-preenchidos com o que já foi conversado na devolutiva. Quando o
/// cliente pediu ajuste, o pedido fica no topo — com a contraproposta pronta
/// para aplicar em um toque.
class ContractTermsPage extends StatefulWidget {
  const ContractTermsPage({super.key});

  @override
  State<ContractTermsPage> createState() => _ContractTermsPageState();
}

class _ContractTermsPageState extends State<ContractTermsPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _scope;
  late final TextEditingController _price;
  late final TextEditingController _paymentTerms;
  late final TextEditingController _warranty;
  late final TextEditingController _materialsNotes;
  late final TextEditingController _additional;
  final _startLabel = TextEditingController();
  final _endLabel = TextEditingController();

  PaymentMethod? _payment;
  MaterialsResponsibility? _materials;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final terms = context.read<ContractDetailCubit>().state.contract!.terms;

    _scope = TextEditingController(text: terms.scope);
    _price = TextEditingController(
      text: terms.priceCents == null ? '' : formatCentsInput(terms.priceCents!),
    );
    _paymentTerms = TextEditingController(text: terms.paymentTerms ?? '');
    _warranty = TextEditingController(text: '${terms.warrantyDays}');
    _materialsNotes = TextEditingController(text: terms.materialsNotes ?? '');
    _additional = TextEditingController(text: terms.additionalTerms ?? '');
    _payment = terms.paymentMethod;
    _materials = terms.materialsResponsibility;
    _setStart(terms.startDate);
    _setEnd(terms.estimatedEndDate);
  }

  @override
  void dispose() {
    for (final controller in [
      _scope,
      _price,
      _paymentTerms,
      _warranty,
      _materialsNotes,
      _additional,
      _startLabel,
      _endLabel,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setStart(DateTime? date) {
    _start = date;
    _startLabel.text = date == null ? '' : formatBrDate(date);
  }

  void _setEnd(DateTime? date) {
    _end = date;
    _endLabel.text = date == null ? '' : formatBrDate(date);
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final initial = (start ? _start : (_end ?? _start)) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null) return;

    setState(() {
      if (start) {
        _setStart(picked);
        if (_end != null && _end!.isBefore(picked)) _setEnd(picked);
      } else {
        _setEnd(picked);
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final missing = _payment == null
        ? 'Escolha a forma de pagamento'
        : _materials == null
        ? 'Diga quem fornece os materiais'
        : null;
    if (missing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(missing), backgroundColor: context.colors.error),
      );
      return;
    }

    final terms = ContractTerms(
      scope: _scope.text.trim(),
      priceCents: parseCents(_price.text),
      paymentMethod: _payment,
      paymentTerms: _paymentTerms.text,
      startDate: _start,
      estimatedEndDate: _end,
      warrantyDays: int.tryParse(_warranty.text) ?? _minWarrantyDays,
      materialsResponsibility: _materials,
      materialsNotes: _materialsNotes.text,
      additionalTerms: _additional.text,
    );

    final saved = await context.read<ContractDetailCubit>().saveTerms(terms);
    if (saved && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = context.watch<ContractDetailCubit>().state;
    final request = state.contract?.changeRequest;

    return Scaffold(
      appBar: const AppBackAppBar(title: 'Termos do contrato'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.xxl,
          ),
          children: [
            if (request != null) ...[
              AppCard(
                bordered: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O cliente pediu ajustes',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      request.message,
                      style: AppTypography.body.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    if (request.counterProposalCents != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Contraproposta: ${formatCents(request.counterProposalCents!)}',
                        style: AppTypography.label.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppSecondaryButton(
                        label: 'Aplicar contraproposta',
                        expanded: false,
                        onPressed: () => setState(
                          () => _price.text = formatCentsInput(
                            request.counterProposalCents!,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const FormSectionTitle('O que será feito'),
            AppTextField(
              controller: _scope,
              label: 'Escopo do serviço',
              helper: 'Seja específico: é isto que o contrato garante.',
              maxLines: 6,
              maxLength: 5000,
              keyboardType: TextInputType.multiline,
              validator: (v) => (v ?? '').trim().length < 20
                  ? 'Descreva o serviço com pelo menos 20 caracteres'
                  : null,
            ),
            const FormSectionTitle('Preço e pagamento'),
            AppTextField(
              controller: _price,
              label: 'Valor total',
              hint: '0,00',
              keyboardType: TextInputType.number,
              inputFormatters: [CentsInputFormatter()],
              prefixIcon: Icons.attach_money_rounded,
              validator: (v) =>
                  parseCents(v ?? '') <= 0 ? 'Informe o valor' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Forma de pagamento',
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final method in PaymentMethod.values)
                  ChoiceChip(
                    label: Text(method.label),
                    selected: _payment == method,
                    onSelected: (_) => setState(() => _payment = method),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.gap),
            AppTextField(
              controller: _paymentTerms,
              label: 'Condições (opcional)',
              hint: 'Ex.: 50% no início e 50% na conclusão',
              maxLines: 2,
              maxLength: 1000,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'A Jobble não intermedeia pagamentos: o cliente paga direto a '
              'você, na forma combinada aqui.',
              style: AppTypography.caption.copyWith(color: colors.textHint),
            ),
            const FormSectionTitle('Prazo'),
            AppTextField(
              controller: _startLabel,
              label: 'Início',
              readOnly: true,
              prefixIcon: Icons.calendar_today_rounded,
              onTap: () => _pickDate(start: true),
              validator: (_) => _start == null ? 'Escolha a data de início' : null,
            ),
            const SizedBox(height: AppSpacing.gap),
            AppTextField(
              controller: _endLabel,
              label: 'Previsão de término',
              readOnly: true,
              prefixIcon: Icons.event_available_rounded,
              onTap: () => _pickDate(start: false),
              validator: (_) =>
                  _end == null ? 'Escolha a previsão de término' : null,
            ),
            const FormSectionTitle('Garantia'),
            AppTextField(
              controller: _warranty,
              label: 'Prazo de garantia (dias)',
              helper: 'Mínimo de $_minWarrantyDays dias — o prazo legal para '
                  'serviços duráveis.',
              keyboardType: TextInputType.number,
              inputFormatters: [digitsOnly],
              validator: (v) => (int.tryParse(v ?? '') ?? 0) < _minWarrantyDays
                  ? 'Pelo menos $_minWarrantyDays dias'
                  : null,
            ),
            const FormSectionTitle('Materiais'),
            for (final option in MaterialsResponsibility.values) ...[
              AppSelectableCard(
                title: option.label,
                subtitle: option.hint,
                selected: _materials == option,
                onTap: () => setState(() => _materials = option),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: _materialsNotes,
              label: _materials == MaterialsResponsibility.shared
                  ? 'Como os materiais serão divididos'
                  : 'Observações sobre materiais (opcional)',
              maxLines: 3,
              maxLength: 1000,
              validator: (v) =>
                  _materials == MaterialsResponsibility.shared &&
                      (v ?? '').trim().isEmpty
                  ? 'Descreva a divisão'
                  : null,
            ),
            const FormSectionTitle('Cláusulas adicionais'),
            AppTextField(
              controller: _additional,
              label: 'Algo mais que as partes combinaram (opcional)',
              maxLines: 4,
              maxLength: 3000,
            ),
            const SizedBox(height: AppSpacing.section),
            AppPrimaryButton(
              label: 'Salvar termos',
              isLoading: state.acting,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
