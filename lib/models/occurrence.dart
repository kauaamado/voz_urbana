import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

enum OccurrenceCategory {
  iluminacaoPublica('Iluminação Pública', Icons.lightbulb, Color(0xFFB45309)),
  pavimentacao('Pavimentação', Icons.construction, Color(0xFFC2410C)),
  saneamento('Saneamento', Icons.water_drop, Color(0xFF0369A1)),
  seguranca('Segurança', Icons.shield, Color(0xFFB91C1C)),
  patrimonio('Patrimônio', Icons.account_balance, Color(0xFF7E22CE)),
  lazer('Lazer', Icons.park, Color(0xFF15803D));

  final String label;
  final IconData icon;
  final Color color;
  const OccurrenceCategory(this.label, this.icon, this.color);
}

class Occurrence {
  final String id;
  final String title;
  final String description;
  final OccurrenceCategory category;
  final LatLng location;
  final String? address;
  final String? imagePath; // Path ou URL da foto
  final DateTime dateTime;

  Occurrence({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.address,
    this.imagePath,
    DateTime? dateTime,
  })  : id = id ?? const Uuid().v4(),
        dateTime = dateTime ?? DateTime.now();

  /// Título final: o digitado (sem espaços nas pontas) ou o nome da categoria.
  static String titleFor(String typed, OccurrenceCategory category) {
    final trimmed = typed.trim();
    return trimmed.isEmpty ? category.label : trimmed;
  }
}
