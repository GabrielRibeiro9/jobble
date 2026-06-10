import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(
          color: context.colors.border.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKeyEvent,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in widget.tags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          color: context.colors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: widget.tags.isEmpty ? 'Digite e pressione Enter' : 'Adicionar...',
                    hintStyle: TextStyle(
                      color: context.colors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
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
