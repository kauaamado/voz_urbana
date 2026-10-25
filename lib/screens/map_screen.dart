import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/occurrence_provider.dart';
import '../theme/design_system.dart';
import 'package:intl/intl.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OccurrenceProvider>(
      builder: (context, provider, child) {
        return FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(-22.5112, -43.1779), // CEFET-RJ Petrópolis
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.voz_urbana',
            ),
            MarkerLayer(
              markers: provider.occurrences.map((occurrence) {
                return Marker(
                  point: occurrence.location,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      _showOccurrenceDetails(context, occurrence);
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: DesignSystem.primary,
                      size: 40,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _showOccurrenceDetails(BuildContext context, dynamic occurrence) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
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
                label: Text(
                  occurrence.category.label,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: DesignSystem.tertiary,
              ),
              const SizedBox(height: 8),
              Text(occurrence.description),
              const SizedBox(height: 8),
              Text(
                'Registrado em: ${DateFormat('dd/MM/yyyy HH:mm').format(occurrence.dateTime)}',
                style: const TextStyle(color: DesignSystem.secondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (occurrence.imagePath != null && occurrence.imagePath.toString().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: occurrence.imagePath!.startsWith('http')
                      ? Image.network(
                          occurrence.imagePath!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(occurrence.imagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}
