
import 'package:flutter/material.dart';

class DropdownTile<T> extends StatelessWidget {
  const DropdownTile({
    super.key,
    required this.label,
    required this.selectedItem,
    required this.onSelected,
    required this.items,
    required this.itemLabelBuilder,
  });

  final String label;
  final T? selectedItem;
  final Function(T?) onSelected;
  final List<T> items;
  final String Function(T) itemLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: DropdownMenu<T>(
          trailingIcon: const Icon(Icons.arrow_drop_down),
          width: MediaQuery.of(context).size.width - 24,
          initialSelection: selectedItem,
          hintText: "Select $label",
          textStyle: theme.textTheme.bodyMedium,
          dropdownMenuEntries: items.map((e) {
            return DropdownMenuEntry<T>(
              value: e,
              label: itemLabelBuilder(e),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onSurface),
              ),
            );
          }).toList(),
          onSelected: (t) => onSelected(t),
        ),
      ),
    );
  }
}
