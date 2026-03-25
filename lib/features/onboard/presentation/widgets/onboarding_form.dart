import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class OnboardingForm extends StatefulWidget {
  final int step;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const OnboardingForm({
    super.key,
    required this.step,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _dateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedActivity;

  final List<String> _genders = ['Homem', 'Mulher', 'Não Binário / Outros'];
  final List<String> _activities = [
    'Tecnologia',
    'Educação',
    'Saúde',
    'Comércio',
    'Indústria',
    'Outros',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _dateController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: CupertinoColors.quaternarySystemFill.resolveFrom(
                  context,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate ?? DateTime(2000),
                minimumYear: 1900,
                maximumYear: DateTime.now().year,
                onDateTimeChanged: (DateTime picked) {
                  setState(() {
                    _selectedDate = picked;
                    _dateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(picked);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(
    BuildContext context,
    List<String> items,
    String? currentValue,
    ValueChanged<String> onSelected,
  ) {
    int selectedIndex = currentValue != null ? items.indexOf(currentValue) : 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: CupertinoColors.quaternarySystemFill.resolveFrom(
                  context,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () {
                      onSelected(items[selectedIndex]);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                onSelectedItemChanged: (int index) {
                  selectedIndex = index;
                },
                children: items
                    .map((text) => Center(child: Text(text)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.step == 0)
          _buildGroupedContainer([
            // ── Nome completo ──
            _buildInputRow(
              label: 'Nome completo',
              icon: LucideIcons.lock,
              child: CupertinoTextField(
                controller: _nameController,
                placeholder: 'Seu nome completo',
                padding: EdgeInsets.zero,
                decoration: null,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),

            // ── Idade (Data) ──
            _buildInputRow(
              label: 'Idade',
              child: GestureDetector(
                onTap: () => _showDatePicker(context),
                child: AbsorbPointer(
                  child: CupertinoTextField(
                    controller: _dateController,
                    placeholder: 'DD/MM/AAAA',
                    padding: EdgeInsets.zero,
                    decoration: null,
                    style: const TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            // ── CPF ──
            _buildInputRow(
              label: 'CPF',
              child: CupertinoTextField(
                controller: _cpfController,
                placeholder: '000.000.000-00',
                padding: EdgeInsets.zero,
                decoration: null,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                keyboardType: TextInputType.number,
                inputFormatters: [_cpfFormatter],
              ),
            ),

            // ── Gênero ──
            _buildInputRow(
              label: 'Gênero',
              child: _buildSelectField(
                context: context,
                value: _selectedGender,
                items: _genders,
                hint: 'Selecione seu gênero',
                onSelected: (val) => setState(() => _selectedGender = val),
              ),
            ),
          ])
        else
          _buildGroupedContainer([
            // ── Nome da empresa ──
            _buildInputRow(
              label: 'Nome do negócio',
              child: CupertinoTextField(
                controller: _companyController,
                placeholder: 'Nome da sua empresa',
                padding: EdgeInsets.zero,
                decoration: null,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),

            // ── CNPJ (Opcional) ──
            _buildInputRow(
              label: 'CNPJ (Opcional)',
              child: CupertinoTextField(
                controller: _cnpjController,
                placeholder: '00.000.000/0000-00',
                padding: EdgeInsets.zero,
                decoration: null,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                keyboardType: TextInputType.number,
                inputFormatters: [_cnpjFormatter],
              ),
            ),

            // ── Ramo de atuação ──
            _buildInputRow(
              label: 'Ramo de atuação',
              child: _buildSelectField(
                context: context,
                value: _selectedActivity,
                items: _activities,
                hint: 'Selecione sua área',
                onSelected: (val) => setState(() => _selectedActivity = val),
              ),
            ),
          ]),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildGroupedContainer(List<Widget> children) {
    List<Widget> itemsWithDividers = [];
    for (int i = 0; i < children.length; i++) {
      itemsWithDividers.add(children[i]);
      if (i < children.length - 1) {
        itemsWithDividers.add(
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: itemsWithDividers,
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required Widget child,
    IconData? icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14, color: Colors.black),
                      const SizedBox(width: 8),
                    ],
                    Expanded(child: child),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );
  }

  Widget _buildSelectField({
    required BuildContext context,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String> onSelected,
  }) {
    return GestureDetector(
      onTap: () => _showPicker(context, items, value, onSelected),
      child: Text(
        value ?? hint,
        style: TextStyle(
          color: value != null ? Colors.black : const Color(0xFF9E9E9E),
          fontSize: 13,
        ),
      ),
    );
  }
}
