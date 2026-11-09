import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/occurrence_provider.dart';

class EmptyOccurrences extends StatelessWidget {
  const EmptyOccurrences({super.key, required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filtered
                ? 'Nenhuma ocorrência neste período'
                : 'Nenhuma ocorrência registrada.',
            style: const TextStyle(fontSize: 14),
          ),
          if (filtered)
            TextButton(
              onPressed: context.read<OccurrenceProvider>().clearFilter,
              child: const Text('Limpar filtro'),
            ),
        ],
      ),
    );
  }
}
