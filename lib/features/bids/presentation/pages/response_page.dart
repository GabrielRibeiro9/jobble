import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/injection_container.dart';
import 'package:flutter_tcc/features/bids/data/datasources/bid_remote_data_source.dart';

class ResponsePage extends StatefulWidget {
  final String serviceMatchId;
  final String clientName;
  final VoidCallback onSubmitted;

  const ResponsePage({
    super.key,
    required this.serviceMatchId,
    required this.clientName,
    required this.onSubmitted,
  });

  @override
  State<ResponsePage> createState() => _ResponsePageState();
}

class _MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '0,00', selection: TextSelection.collapsed(offset: 4));
    }
    final cents = int.parse(digits);
    final display = (cents / 100).toStringAsFixed(2).replaceFirst('.', ',');
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}

class _ResponsePageState extends State<ResponsePage> {
  final dataSource = BidRemoteDataSource(dioClient: sl<DioClient>());
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController(text: '0,00');
  bool _isImmediate = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _submitting = false;

  int get _cents {
    final digits = _valueController.text.replaceAll(RegExp(r'[^\d]'), '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 8))),
      );
      if (time != null && mounted) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isImmediate && (_selectedDate == null || _selectedTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de atendimento')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final value = _cents / 100.0;
      String? proposedDate;
      if (!_isImmediate && _selectedDate != null && _selectedTime != null) {
        final dateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        proposedDate = dateTime.toIso8601String();
      }

      await dataSource.respondToMatch(
        serviceMatchId: widget.serviceMatchId,
        bidValue: value,
        serviceType: _isImmediate ? 'IMMEDIATE' : 'SCHEDULED',
        proposedDate: proposedDate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposta enviada com sucesso!')),
      );
      widget.onSubmitted();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar proposta: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
        title: const Text('Responder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.md,
          AppSpacing.screenH,
          AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Proposta para ${widget.clientName}',
                style: AppTypography.h2.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.section),
              AppTextField(
                controller: _valueController,
                label: 'Valor do serviço',
                hint: '0,00',
                keyboardType: TextInputType.number,
                inputFormatters: [_MoneyInputFormatter()],
                prefixIcon: Icons.attach_money_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o valor';
                  final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Tipo de atendimento',
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppSelectableCard(
                title: 'Atendimento imediato',
                subtitle: 'Posso realizar o serviço assim que for aceito',
                selected: _isImmediate,
                onTap: () => setState(() {
                  _isImmediate = true;
                  _selectedDate = null;
                  _selectedTime = null;
                }),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppSelectableCard(
                title: 'Serviço agendado',
                subtitle: 'Preciso marcar uma data para realizar o serviço',
                selected: !_isImmediate,
                onTap: () => setState(() => _isImmediate = false),
              ),
              if (!_isImmediate) ...[
                const SizedBox(height: AppSpacing.md),
                AppFieldGroup(
                  label: 'Data do atendimento',
                  child: GestureDetector(
                    onTap: _pickDate,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      height: AppSize.field,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(
                          color: colors.border,
                          width: AppSize.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _scheduleLabel(),
                              style: AppTypography.body.copyWith(
                                color: _selectedDate != null
                                    ? colors.textPrimary
                                    : colors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.section),
              AppPrimaryButton(
                label: 'Enviar proposta',
                isLoading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _scheduleLabel() {
    final date = _selectedDate;
    final time = _selectedTime;
    if (date == null || time == null) return 'Selecionar data e horário';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} às ${hour}h$minute';
  }

}
