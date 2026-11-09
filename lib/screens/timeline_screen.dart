import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/occurrence.dart';
import '../providers/occurrence_provider.dart';
import '../theme/design_system.dart';
import '../widgets/empty_occurrences.dart';
import '../widgets/filter_bar.dart';
import '../widgets/occurrence_detail_sheet.dart';
import '../widgets/occurrence_image.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FilterBar(),
        Expanded(
          child: Consumer<OccurrenceProvider>(
            builder: (context, provider, child) {
              final occurrences = provider.occurrences;

              if (occurrences.isEmpty) {
                return EmptyOccurrences(filtered: provider.hasActiveFilter);
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // Espaço pro FAB
                itemCount: occurrences.length,
                itemBuilder: (context, index) =>
                    _OccurrenceCard(occurrence: occurrences[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OccurrenceCard extends StatelessWidget {
  const _OccurrenceCard({required this.occurrence});

  final Occurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final path = occurrence.imagePath;
    final hasPhoto = path != null && path.isNotEmpty;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.cardRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => showOccurrenceDetails(context, occurrence),
        child: Padding(
          padding: DesignSystem.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Chip(
                            avatar: Icon(occurrence.category.icon,
                                size: 18, color: occurrence.category.color),
                            label: Text(occurrence.category.label,
                                style: const TextStyle(fontSize: 14)),
                            backgroundColor: DesignSystem.tertiary,
                            side: BorderSide.none,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(occurrence.dateTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      occurrence.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (occurrence.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        occurrence.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    if (occurrence.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        occurrence.address!,
                        style: const TextStyle(
                            color: DesignSystem.secondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasPhoto) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: OccurrenceImage(path: path, width: 72, height: 72),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
