import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/occurrence.dart';
import '../theme/design_system.dart';
import 'occurrence_image.dart';

/// Detalhe de uma ocorrência, usado pelo Mapa e pela Linha do Tempo.
void showOccurrenceDetails(BuildContext context, Occurrence occurrence) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            occurrence.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.primary,
                ),
          ),
          const SizedBox(height: 8),
          Chip(
            avatar: Icon(occurrence.category.icon,
                size: 18, color: occurrence.category.color),
            label: Text(occurrence.category.label,
                style: const TextStyle(fontSize: 14)),
            backgroundColor: DesignSystem.tertiary,
          ),
          if (occurrence.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(occurrence.description, style: const TextStyle(fontSize: 14)),
          ],
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  occurrence.address ?? 'Endereço indisponível',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Registrado em: ${DateFormat('dd/MM/yyyy HH:mm').format(occurrence.dateTime)}',
            style: const TextStyle(color: DesignSystem.secondary, fontSize: 12),
          ),
          if (occurrence.imagePath != null && occurrence.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: OccurrenceImage(
                path: occurrence.imagePath!,
                height: 200,
                width: double.infinity,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
