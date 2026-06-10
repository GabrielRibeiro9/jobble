import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
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
        title: const Text('Responder Solicitação'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Responder para ${widget.clientName}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Valor do Serviço',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                inputFormatters: [_MoneyInputFormatter()],
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                  filled: true,
                  fillColor: colors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                style: TextStyle(color: colors.textPrimary, fontSize: 16),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o valor';
                  final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Tipo de Atendimento',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _serviceTypeOption(colors, true, 'Atendimento Imediato',
                  'Posso realizar o serviço assim que for aceito'),
              const SizedBox(height: 8),
              _serviceTypeOption(colors, false, 'Serviço Agendado',
                  'Preciso agendar uma data para realizar o serviço'),
              if (!_isImmediate) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: colors.textSecondary),
                        const SizedBox(width: 10),
                        Text(
                          _selectedDate != null && _selectedTime != null
                              ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year} às ${_selectedTime!.hour.toString().padLeft(2, '0')}h${_selectedTime!.minute.toString().padLeft(2, '0')}'
                              : 'Selecionar data e horário',
                          style: TextStyle(
                            color: _selectedDate != null ? colors.textPrimary : colors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _submitting
                      ? const Padding(
                          padding: EdgeInsets.all(2),
                          child: AppLoader(),
                        )
                      : const Text('Enviar Proposta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceTypeOption(AppColorsTheme colors, bool value, String title, String subtitle) {
    return InkWell(
      onTap: () => setState(() {
        _isImmediate = value;
        if (value) {
          _selectedDate = null;
          _selectedTime = null;
        }
      }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isImmediate == value ? colors.themePrimary.withValues(alpha: 0.08) : colors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isImmediate == value ? colors.themePrimary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: value,
              groupValue: _isImmediate,
              onChanged: (v) => setState(() => _isImmediate = v ?? true),
              activeColor: colors.themePrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
