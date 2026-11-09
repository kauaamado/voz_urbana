import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Foto de uma ocorrência: URL (http/https) ou arquivo local.
/// Se não carregar, mostra um ícone em vez de lançar exceção.
class OccurrenceImage extends StatelessWidget {
  const OccurrenceImage({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget broken(BuildContext context, Object error, StackTrace? stack) => Container(
          height: height,
          width: width,
          color: DesignSystem.tertiary,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, color: DesignSystem.secondary),
        );

    return path.startsWith('http')
        ? Image.network(path, height: height, width: width, fit: fit, errorBuilder: broken)
        : Image.file(File(path), height: height, width: width, fit: fit, errorBuilder: broken);
  }
}
