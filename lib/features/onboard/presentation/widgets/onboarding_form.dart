import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _dateController = TextEditingController();
  
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
    'Outros'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: const Color.fromARGB(255, 32, 32, 32),
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Nome completo ──
        _buildLabel('Nome completo'),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Seu nome completo',
          ),
        ),

        const SizedBox(height: 20),

        // ── Idade (Data) ──
        _buildLabel('Idade'),
        const SizedBox(height: 8),
        TextField(
          controller: _dateController,
          readOnly: true,
          onTap: () => _selectDate(context),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'DD/MM/AAAA',
            suffixIcon: Icon(
              Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Gênero ──
        _buildLabel('Gênero'),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _selectedGender,
          items: _genders,
          hint: 'Selecione seu gênero',
          onChanged: (val) => setState(() => _selectedGender = val),
        ),

        const SizedBox(height: 20),

        // ── Ramo de atuação ──
        _buildLabel('Ramo de atuação'),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _selectedActivity,
          items: _activities,
          hint: 'Selecione sua área',
          onChanged: (val) => setState(() => _selectedActivity = val),
        ),

        const SizedBox(height: 20),

        // ── Nome da empresa (Opcional) ──
        _buildLabel('Nome da empresa (opcional)'),
        const SizedBox(height: 8),
        TextField(
          controller: _companyController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Nome da sua empresa',
          ),
        ),

        const SizedBox(height: 32),

        // ── Botão Continuar ──
        ElevatedButton(
          onPressed: () {
            // TODO: Submit onboarding
          },
          child: const Text(
            'Continuar',
            style: TextStyle(
              color: AppColors.background,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: const Color.fromARGB(255, 32, 32, 32),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.textSecondary,
        size: 20,
      ),
      decoration: InputDecoration(
        hintText: hint,
        // Remover constraints de altura para o dropdown se necessário,
        // mas aqui estamos usando o tema padrão.
        // Se o tema estiver com maxHeight 36, o dropdown pode ficar estranho.
        // Vou forçar uma altura mínima no formulário ou sobrescrever aqui se falhar.
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
