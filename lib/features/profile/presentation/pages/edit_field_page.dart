import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_text_field.dart';

class EditFieldPage extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String currentValue;
  final Future<void> Function(String value) onSave;

  const EditFieldPage({
    super.key,
    required this.title,
    required this.fieldLabel,
    required this.currentValue,
    required this.onSave,
  });

  @override
  State<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  late TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newValue = _controller.text.trim();
    if (newValue.isEmpty) return;
    if (newValue == widget.currentValue) {
      Navigator.pop(context);
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(newValue);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: AppSize.iconButton + AppSpacing.md + AppSpacing.xs,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppCircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Voltar',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.xl,
          AppSpacing.screenH,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _controller,
              label: widget.fieldLabel,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saving ? null : _save(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Salvar',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
