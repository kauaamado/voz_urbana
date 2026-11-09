import 'package:flutter/material.dart';
import '../models/occurrence.dart';
import 'occurrence_image.dart';

/// Pino do mapa: miniatura da foto (se houver) ou ícone da categoria.
class OccurrenceMarker extends StatelessWidget {
  const OccurrenceMarker({
    super.key,
    required this.occurrence,
    required this.onTap,
  });

  final Occurrence occurrence;
  final VoidCallback onTap;

  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    final category = occurrence.category;
    final path = occurrence.imagePath;
    final hasPhoto = path != null && path.isNotEmpty;

    return Semantics(
      button: true,
      label: '${occurrence.title}, ${category.label}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: category.color, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: ClipOval(
            child: hasPhoto
                ? OccurrenceImage(path: path, width: size, height: size)
                : Icon(category.icon, color: category.color, size: 24),
          ),
        ),
      ),
    );
  }
}
