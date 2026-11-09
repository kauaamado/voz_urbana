import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/occurrence_provider.dart';
import '../theme/design_system.dart';

/// Filtro de período compartilhado por Mapa e Linha do Tempo (mesmo estado).
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  Future<void> _pick(BuildContext context, OccurrenceProvider provider) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: DesignSystem.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) provider.setFilterDateRange(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OccurrenceProvider>();
    final fmt = DateFormat('dd/MM');
    final count = provider.hasActiveFilter ? provider.occurrences.length : 0;

    return Container(
      width: double.infinity, // ocupa a largura toda também dentro de uma Column
      color: DesignSystem.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          TextButton.icon(
            onPressed: () => _pick(context, provider),
            icon: const Icon(Icons.calendar_month, color: DesignSystem.primary),
            label: const Text(
              'Filtrar período',
              style: TextStyle(color: DesignSystem.primary, fontSize: 14),
            ),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, DesignSystem.minTouchTarget),
            ),
          ),
          if (provider.hasActiveFilter) ...[
            InputChip(
              label: Text(
                '${fmt.format(provider.filterStartDate!)} – ${fmt.format(provider.filterEndDate!)}',
                style: const TextStyle(fontSize: 14),
              ),
              deleteButtonTooltipMessage: 'Limpar filtro',
              onDeleted: provider.clearFilter,
            ),
            Semantics(
              liveRegion: true, // leitores de tela anunciam a nova contagem
              child: Text(
                count == 1 ? '1 ocorrência' : '$count ocorrências',
                style: const TextStyle(color: DesignSystem.secondary, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
