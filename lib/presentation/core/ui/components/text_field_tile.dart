import 'dart:async';

import 'package:flutter/material.dart';

class TextFieldTile extends StatefulWidget {
   TextFieldTile({
    super.key,
    required this.label,
    String? initialValue,
    TextEditingController? controller,
    this.onDebouncedChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.hintText,
    this.minLines,
  }) : controller = controller ?? TextEditingController(text: initialValue);

  final String label;
  final TextEditingController controller;
  final Function(String)? onDebouncedChanged;
  final Duration debounceDuration;
  final String? hintText;
  final int? minLines;

  @override
  State<TextFieldTile> createState() => _TextFieldTileState();
}

class _TextFieldTileState extends State<TextFieldTile> {
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onDebouncedChanged?.call(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextFormField(
            controller: widget.controller,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: widget.hintText),
            onChanged: _onChanged,
            minLines: widget.minLines,
            maxLines: widget.minLines != null ? null : 1,
          ),
        ],
      ),
    );
  }
}
