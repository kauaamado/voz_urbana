import 'package:flutter/material.dart';
import '../models/occurrence.dart';
import '../theme/design_system.dart';

/// Seleção única de categoria, com ícone e rótulo.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OccurrenceCategory? selected;
  final ValueChanged<OccurrenceCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: OccurrenceCategory.values.map((category) {
        final isSelected = category == selected;
        return ChoiceChip(
          avatar: Icon(
            category.icon,
            size: 18,
            color: isSelected ? Colors.white : category.color,
          ),
          label: Text(category.label, style: const TextStyle(fontSize: 14)),
          selected: isSelected,
          showCheckmark: false,
          selectedColor: DesignSystem.primary,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: (_) => onSelected(category),
        );
      }).toList(),
    );
  }
}
