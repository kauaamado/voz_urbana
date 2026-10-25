import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/occurrence_provider.dart';
import '../theme/design_system.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterHeader(context),
        Expanded(
          child: Consumer<OccurrenceProvider>(
            builder: (context, provider, child) {
              final occurrences = provider.occurrences;

              if (occurrences.isEmpty) {
                return const Center(
                  child: Text('Nenhuma ocorrência registrada.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // Espaço pro FAB
                itemCount: occurrences.length,
                itemBuilder: (context, index) {
                  final occurrence = occurrences[index];
                  return Card(
                    // Seguindo o Design System: sem sombras pesadas
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.cardRadius),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: DesignSystem.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(
                                  occurrence.category.label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: DesignSystem.tertiary,
                                side: BorderSide.none,
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(occurrence.dateTime),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            occurrence.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            occurrence.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    return Container(
      color: DesignSystem.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Histórico de Registros',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Consumer<OccurrenceProvider>(
            builder: (context, provider, child) {
              final hasFilter = provider.filterStartDate != null;
              return TextButton.icon(
                onPressed: () async {
                  if (hasFilter) {
                    provider.clearFilter();
                  } else {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: DesignSystem.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      provider.setFilterDateRange(picked.start, picked.end);
                    }
                  }
                },
                icon: Icon(
                  hasFilter ? Icons.filter_alt_off : Icons.filter_alt,
                  color: DesignSystem.primary,
                ),
                label: Text(
                  hasFilter ? 'Limpar' : 'Filtrar',
                  style: const TextStyle(color: DesignSystem.primary),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
