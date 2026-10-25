import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

enum OccurrenceCategory {
  iluminacaoPublica('Iluminação Pública'),
  pavimentacao('Pavimentação'),
  saneamento('Saneamento'),
  seguranca('Segurança'),
  patrimonio('Patrimônio'),
  lazer('Lazer');

  final String label;
  const OccurrenceCategory(this.label);
}

class Occurrence {
  final String id;
  final String title;
  final String description;
  final OccurrenceCategory category;
  final LatLng location;
  final String? imagePath; // Path ou URL da foto
  final DateTime dateTime;

  Occurrence({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.imagePath,
    DateTime? dateTime,
  })  : id = id ?? const Uuid().v4(),
        dateTime = dateTime ?? DateTime.now();
}
