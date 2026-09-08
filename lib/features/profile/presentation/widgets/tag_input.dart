import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

class TagInput extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagInput({
    super.key,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(TagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tags != widget.tags && widget.tags.isEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final tag = value.trim().replaceAll(RegExp(r'[;,\s]+$'), '').trim();
    if (tag.isEmpty) return;
    if (widget.tags.contains(tag)) return;
    final updated = [...widget.tags, tag];
    widget.onTagsChanged(updated);
  }

  void _removeTag(String tag) {
    final updated = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(updated);
  }

  void _onTextFieldSubmitted(String value) {
    _addTag(value);
    _controller.clear();
  }

  void _onTextFieldChanged(String value) {
    if (value.contains(',') || value.contains(';')) {
      final parts = value.split(RegExp(r'[;,]'));
      for (final part in parts) {
        _addTag(part);
      }
      _controller.clear();
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty &&
        widget.tags.isNotEmpty) {
      _removeTag(widget.tags.last);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border, width: AppSize.border),
        borderRadius: AppRadius.mdAll,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKeyEvent,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in widget.tags)
                // Chip removível: pill em lima sobre superfície, como qualquer
                // outro elemento selecionado do sistema.
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xxs + 2,
                    AppSpacing.xs,
                    AppSpacing.xxs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: AppTypography.label.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: colors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _controller,
                  cursorColor: colors.primary,
                  decoration: InputDecoration(
                    hintText: widget.tags.isEmpty
                        ? 'Digite e pressione Enter'
                        : 'Adicionar...',
                    hintStyle: AppTypography.body.copyWith(
                      color: colors.textHint,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    isDense: true,
                  ),
                  style: AppTypography.body.copyWith(
                    color: colors.textPrimary,
                  ),
                  onSubmitted: _onTextFieldSubmitted,
                  onChanged: _onTextFieldChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
