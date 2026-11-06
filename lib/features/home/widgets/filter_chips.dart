import 'package:flutter/material.dart';
import 'package:sprig/state/plant_view_model.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/widgets/category_icon.dart';
import 'package:sprig/widgets/choice_chip.dart';

/// Baris chip filter kategori yang bisa digeser ke samping.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PlantFilter selected;
  final ValueChanged<PlantFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const filters = PlantFilter.values;
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => Center(
          child: AppChoiceChip(
            label: filters[i].label,
            selected: filters[i] == selected,
            leading: _categoryOf(filters[i]) == null
                ? null
                : CategoryIcon(
                    category: _categoryOf(filters[i])!,
                    active: filters[i] == selected,
                  ),
            onTap: () => onChanged(filters[i]),
          ),
        ),
      ),
    );
  }

  static PlantCategory? _categoryOf(PlantFilter filter) => switch (filter) {
        PlantFilter.indoor => PlantCategory.indoor,
        PlantFilter.succulent => PlantCategory.succulent,
        PlantFilter.herb => PlantCategory.herb,
        PlantFilter.outdoor => PlantCategory.outdoor,
        _ => null,
      };
}
